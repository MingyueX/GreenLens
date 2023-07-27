import io
import math
import numpy as np
from skimage import measure
from scipy.ndimage import interpolation
from scipy import spatial
from scipy import stats
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

# Used for trunk boundary line scans
PERCENT_INLIERS_HIGH = 0.60
PERCENT_INLIERS_LOW = 0.50

# Used to identify too-small
# depth image components
ALPHA = 300

# Used to identify appropriately dense
# filtered depth image shapes
BETA = 0.60

# Camera calibration constants
CALIB_DEPTH = 1.0  # Units in m
CALIB_PIXEL_PER_METER = 356.25  # Units in p
WIDTH_SCALE_FACTOR = 1.018  # scale the width based on current observation,
# may not be the most accurate


class Error(Exception):
    """Base class for exceptions in this module."""

    pass


class MissingDepthError(Error):
    """Exception raised when the capture has insufficient depth values."""

    message = "Unable to process image, no depth points found"


class NoTrunkFoundError(Error):
    """Exception raised when no trunk is found in the image."""

    message = "Unable to find trunk in depth image"


def denoise(depth):
    """Remove outlier components from filtered depth image."""

    # label each pixel by connected component of image
    # The 0th label will contain background pixels (pixels with depth value 0)
    labeled = measure.label(depth > 0, connectivity=1, background=0)
    labels, counts = np.unique(labeled, return_counts=True)

    # Zero out depth points in tiny connected components (fewer than ALPHA pixels)
    # tiny = labels_target[np.where(counts[labels_target] < ALPHA)]
    tiny = labels[np.where(counts[labels] < ALPHA)]
    depth[np.isin(labeled, tiny)] = 0.0

    # If the remaining components are not sufficiently "dense" to likely represent
    # a tree trunk, remove them  until they are.

    # Relabel.
    labeled = measure.label(depth > 0, connectivity=1, background=0)
    labels, counts = np.unique(labeled, return_counts=True)

    # Omit the background.
    if labels[0] == 0:
        labels = labels[1:]
        counts = counts[1:]

    # If there was only background left, this is a bad image
    if len(labels) == 0:
        raise NoTrunkFoundError

    # Sort components by their distance from the mean of the target component
    # This is the order in which we will remove them, if necessary.
    # Find the mean x-value of each component:
    means = np.zeros(labels.shape)
    for l in labels:
        xs = np.argwhere(labeled == l)[:, 1]
        means[l - 1] = np.mean(xs)
    # The target component is the largest component
    target_component = labels[np.argmax(counts)]
    target_mean = means[target_component - 1]
    diff_from_target = np.abs(means - target_mean)
    sorted_inds = diff_from_target.argsort()
    sorted_labels = labels[sorted_inds[::-1]]

    inlier_area = np.sum(counts)
    for i in range(len(sorted_labels) - 1):  # Must keep at least one component
        # Check that the convex hull of the components is sufficiently dense in trunk inliers
        # by examining the ratio of the pixel area in remaining components
        # to the total area of the convex hull
        # ConvexHull computed using http://www.qhull.org/
        hull = spatial.ConvexHull(np.argwhere(depth > 0))
        hull_density = inlier_area / hull.volume
        if hull_density > BETA:
            return depth
        else:
            # If not, remove the component whose x-mean is furhest from the target component
            remove = sorted_labels[i]
            depth[labeled == remove] = 0.0
            labeled[labeled == remove] = 0
            inlier_area = inlier_area - counts[remove - 1]

    return depth


def find_boundaries(depth_denoise, depth_filtered):
    """Find trunk boundaries on denoised and filtered depth image."""
    angle = get_rotate_angle(depth_denoise)

    depth_filtered_mask = (depth_filtered > 0) * 1
    depth_filtered_mask_rotated = interpolation.rotate(
        depth_filtered_mask * 1, angle, reshape=False
    )
    depth_filtered_mask_rotated = (np.abs(depth_filtered_mask_rotated) > 0.003) * 1

    # Move in from the left side until reaching a vertical scanline
    # with at least PERCENT_INLIERS_HIGH percent of points in the filtered
    # trunk range.
    left_boundary = 0
    for j in range(SHAPE[1]):
        counts = np.bincount(depth_filtered_mask_rotated[:, j])
        if len(counts) < 2:
            continue
        if counts[1] / (counts[0] + counts[1]) > PERCENT_INLIERS_HIGH:
            left_boundary = j
            break
    # Starting from the left boundary, move out to the left again until
    # the first vertical scanline with less than PERCENT_INLIERS_LOW percent
    # of points in the filtered trunk range. Choose the boundary just to the right.
    for j in range(left_boundary - 1, -1, -1):
        counts = np.bincount(depth_filtered_mask_rotated[:, j])
        if len(counts) < 2:
            continue
        if counts[1] / (counts[0] + counts[1]) < PERCENT_INLIERS_LOW:
            left_boundary = j + 1
            break

    # Move in from the right side until reaching a vertical scanline
    # with at least PERCENT_INLIERS_HIGH percent of points in the filtered
    # trunk range.
    right_boundary = 0
    for j in range(SHAPE[1] - 1, -1, -1):
        counts = np.bincount(depth_filtered_mask_rotated[:, j])
        if len(counts) < 2:
            continue
        if counts[1] / (counts[0] + counts[1]) > PERCENT_INLIERS_HIGH:
            right_boundary = j
            break

    # Starting from the right boundary, move out to the right again until
    # the first vertical scanline with less than PERCENT_INLIERS_LOW percent
    # of points in the filtered trunk range. Choose the boundary just to the left.
    for j in range(right_boundary, SHAPE[1]):
        counts = np.bincount(depth_filtered_mask_rotated[:, j])
        if len(counts) < 2:
            continue
        if counts[1] / (counts[0] + counts[1]) < PERCENT_INLIERS_LOW:
            right_boundary = j - 1
            break

    return angle, left_boundary, right_boundary


# rotates the matrix to vertical based on binary encoding
def get_rotate_angle(matrix):
    """Compute angle to rotate binary encoded image to vertical."""
    x = np.array(np.where(matrix > 0)).T

    # Perform a PCA and compute the angle of the first principal axes
    pca = PCA(n_components=2).fit(x)

    # Angle of the eigenvectors to the horizontal axis
    # NOTE: numpy expects ([y-values], [x-values])
    angles = np.arctan2(pca.components_[:, 1], pca.components_[:, 0])
    angles = np.rad2deg(angles)

    # We are using the eigenvector to define an axis,
    # but adding 180 degrees identifies the same axis.
    # Therefore, we restrict our angle to be between [0, 180]
    # (The tree always points "up" though it may lean left or right.)
    angles = np.mod(angles, 180)

    # PCA returns two eigenvectors.
    # In most cases, the first runs along the principal axis of the trunk.
    # However, sometimes we get the perpendicular eigenvector.
    # We assume that the tree is relatively upright,
    # and the correct eigenvector is within 60 degrees of vertical.
    # (See also Kour et al.)
    if abs(90 - angles[0]) < 60:
        angle = angles[0]
    else:
        angle = angles[1]

    # Arctan returned an angle from the horizontal axis, but we are looking for
    # the angle off the vertical axis
    # (how far the image must be rotated to make the trunk vertical)
    return 90 - angle


# calculate the final width
def get_estimated_width(depth, pixels):
    return (
        abs((depth * pixels) / (CALIB_DEPTH * CALIB_PIXEL_PER_METER))
        * WIDTH_SCALE_FACTOR
    )


def get_estimated_width_2(depth, pixels):
    return abs(depth * pixels) / ((CALIB_DEPTH * CALIB_PIXEL_PER_METER - (pixels / 4)))


def process(depth, rgb):
    """Process depth and rgb image to find trunk diameter.
    Args:
            depth (np.array(360, 480, dtype=np.float64)): ToF image.
            rgb (np.array(360, 480, 3, dtype=np.float64)): RGB image.
    Returns:
            angle (float): rotation angle
            left, right (int): left and right trunk boundaries
            depth (float): estimated depth of trunk
            width (float): estimated trunk diameter
    """


    global SHAPE
    SHAPE = (rgb.shape[0], rgb.shape[1])
    global CENTER_BOUNDS
    CENTER_BOUNDS = (int(SHAPE[1]/3), 2 * int(SHAPE[1]/3))

    # get filtered depth data and filtered rgb-d image
    # depth data from center third of image
    center_depths = depth[:, CENTER_BOUNDS[0] : CENTER_BOUNDS[1]]
    if np.sum(center_depths) == 0:
        raise MissingDepthError

    processor_log_info = f"Max value in center_depths: {np.max(center_depths)}\n"

    """
    if np.isnan(center_depths).any() or np.isinf(center_depths).any():
        processor_log_info += "center_depths contains NaN or infinite values."
    plot_image_io = io.BytesIO()
    try:
        center_depths_flat = center_depths.flatten()
        sample_center_depths = np.random.choice(center_depths_flat, size=10000)
        plt.hist(sample_center_depths, bins=200, alpha=0.7, label='center_depths')
        plt.title("Center Depth values distribution")
        plt.xlabel("Depth (m)")
        plt.ylabel("Frequency")
        plt.savefig(plot_image_io, format='png')
    except Exception as e:
        print(f"Exception occurred: {e}")
    center_depth_plot = plot_image_io.getvalue()
    plot_image_io.close()
    """

    # Sensor range gives us a maximum of 5 meters away,
    # For now we'll try 3cm resolution
    bins = np.arange(0.0, 10.0, 0.03)
    digitized_center_depths = np.digitize(center_depths[center_depths != 0], bins)

    mode_value = stats.mode(digitized_center_depths, axis=None).mode[0]
    processor_log_info += f"Mode value in digitized_center_depths: {mode_value}\n"
    mode_depth = bins[mode_value]
    # Apply bias correction
    mode_depth = (mode_depth + 0.0216) / 1.04

    # mode_depth = bins[stats.mode(digitized_center_depths, axis=None).mode[0]]
    processor_log_info += f"Mode depth: {mode_depth}\n"

    # zero out depth values that are not within 10% of the mode center depth
    depth_approx = 0.1 * mode_depth
    depth_filtered = depth
    depth_filtered[np.abs(depth - mode_depth) > depth_approx] = 0.0

    # denoise
    depth_denoise = denoise(np.copy(depth_filtered))

    # rotate image to fit the tree vertically and approximate with vertical lines
    angle, left, right = find_boundaries(depth_denoise, depth_filtered)

    # calculate the final estimated width
    estimated_width = get_estimated_width_2(mode_depth, right - left)

    # Apply bias correction
    estimated_width = (estimated_width + 0.0181) / 1.34


    return angle, left, right, mode_depth, estimated_width, processor_log_info
