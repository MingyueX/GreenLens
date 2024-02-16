import cv2
import numpy as np
from skimage import measure
from scipy import spatial
import numpy as np
from scipy import stats
import os
import json

os.chdir(os.path.dirname(__file__))

SHAPE = (360, 480)
ALPHA = 300
ALPHA_MIDDLE = 150
ALPHA_MIDDLE_POOR = 100
BETA = 0.60

class Error(Exception):
    """Base class for exceptions in this module."""
    pass

class NoTrunkFoundError(Error):
    """Exception raised when no trunk is found in the image."""

    def __init__(self):
        self.message = "Unable to find trunk in depth image"
        super().__init__(self.message)

class ParallelLineNotFoundError(Error):
    """Exception raised when no parallel line is found in the image."""

    def __init__(self, message="Unable to find parallel line in edge image"):
        self.message = message
        super().__init__(self.message)

def suppress_green(img):
    """To suppress the preponderance of green in the image

    Args:
        img (ndarray with 3 dimensions,eg.[360,480,3]): RBG image

    Returns:
        result (ndarray with 3 dimensions,eg.[360,480,3]): HSV with green suppression
    """
    # Converting images from BGR color space to HSV color space
    hsv_image = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Defining the green HSV range
    lower_green = np.array([40, 50, 60])
    upper_green = np.array([70, 255, 255])

    # Creating masks based on HSV ranges
    green_mask = cv2.inRange(hsv_image, lower_green, upper_green)
    result = cv2.bitwise_and(img, img, mask=~green_mask)
    result = cv2.cvtColor(result, cv2.COLOR_HSV2RGB)
    return result

def enhance_brown(img):
    """To enhance the brown portion in the image

    Args:
        img (ndarray with 3 dimensions,eg.[360,480,3]): RBG image

    Returns:
        result (ndarray with 3 dimensions,eg.[360,480,3]): HSV with brown enhancement
    """
    # read the brown HSV
    with open("h_ranges.txt") as f:
        h_brown = []
        for line in f.readlines():
            a, b = [int(x) for x in line.split(',')]
            h_brown.append((a, b))
    with open('s_ranges.txt') as f:
        s_brown = []
        for line in f.readlines():
            a, b = [int(x) for x in line.split(',')]
            s_brown.append((a, b))
    with open('v_ranges.txt') as f:
        v_brown = []
        for line in f.readlines():
            a, b = [int(x) for x in line.split(',')]
            v_brown.append((a, b))
    hsv_image = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    # create a mask
    mask = np.zeros(hsv_image.shape[:2], dtype=np.uint8)
    # start_time = time.time()
    for h_range, s_range, v_range in zip(h_brown, s_brown, v_brown):
        lower = np.array([h_range[0], s_range[0], v_range[0]])
        upper = np.array([h_range[1], s_range[1], v_range[1]])
        mask1 = cv2.inRange(hsv_image, lower, upper)
        mask = cv2.bitwise_or(mask, mask1)
    extracted_image = cv2.bitwise_and(img, img, mask=mask)

    return extracted_image

def suppress_and_enhance(img):
    """Suppress green and enhance brown in the image.

    Args:
        img (cv2BGRimg, 360*480*3): BGR image read by cv2.imread
    """

    with open("h_ranges.txt") as f:
        h_brown = []
        for line in f.readlines():
            a, b = [int(x) for x in line.split(',')]
            h_brown.append((a, b))
    with open('s_ranges.txt') as f:
        s_brown = []
        for line in f.readlines():
            a, b = [int(x) for x in line.split(',')]
            s_brown.append((a, b))
    with open('v_ranges.txt') as f:
        v_brown = []
        for line in f.readlines():
            a, b = [int(x) for x in line.split(',')]
            v_brown.append((a, b))
    hsv_image = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    # create a mask
    mask = np.zeros(hsv_image.shape[:2], dtype=np.uint8)
    # start_time = time.time()
    for h_range, s_range, v_range in zip(h_brown, s_brown, v_brown):
        lower = np.array([h_range[0], s_range[0], v_range[0]])
        upper = np.array([h_range[1], s_range[1], v_range[1]])
        mask1 = cv2.inRange(hsv_image, lower, upper)
        mask = cv2.bitwise_or(mask, mask1)

    ### Green mask
    lower_green = np.array([40, 70, 50])
    upper_green = np.array([75, 255, 255])
    green_mask = cv2.inRange(hsv_image, lower_green, upper_green)

    lower_green1 = np.array([90, 45, 150])
    upper_green1 = np.array([100, 80, 200])
    green_mask1 = cv2.inRange(hsv_image, lower_green1, upper_green1)

    lower_green2 = np.array([80, 105, 160])
    upper_green2 = np.array([90, 115, 170])
    green_mask2 = cv2.inRange(hsv_image, lower_green2, upper_green2)

    lower_green3 = np.array([60, 15, 65])
    upper_green3 = np.array([100, 110, 175])
    green_mask3 = cv2.inRange(hsv_image, lower_green3, upper_green3)

    lower_green4 = np.array([30, 0, 230])
    upper_green4 = np.array([40, 50, 255])
    green_mask4 = cv2.inRange(hsv_image, lower_green4, upper_green4)

    lower_green5 = np.array([80, 15, 180])
    upper_green5 = np.array([95, 35, 200])
    green_mask5 = cv2.inRange(hsv_image, lower_green5, upper_green5)

    lower_green7 = np.array([45, 10, 200])
    upper_green7 = np.array([60, 55, 255])
    green_mask7 = cv2.inRange(hsv_image, lower_green7, upper_green7)

    lower_green8 = np.array([30, 60, 150])
    upper_green8 = np.array([35, 190, 255])
    green_mask8 = cv2.inRange(hsv_image, lower_green8, upper_green8)

    lower_green9 = np.array([80, 20, 180])
    upper_green9 = np.array([110, 35, 225])
    green_mask9 = cv2.inRange(hsv_image, lower_green9, upper_green9)

    lower_green10 = np.array([45, 30, 140])
    upper_green10 = np.array([75, 80, 205])
    green_mask10 = cv2.inRange(hsv_image, lower_green10, upper_green10)

    lower_green11 = np.array([55, 5, 180])
    upper_green11 = np.array([80, 70, 255])
    green_mask11 = cv2.inRange(hsv_image, lower_green11, upper_green11)

    lower_green12 = np.array([85, 85, 175])
    upper_green12 = np.array([90, 95, 185])
    green_mask12 = cv2.inRange(hsv_image, lower_green12, upper_green12)

    lower_green13 = np.array([75, 60, 175])
    upper_green13 = np.array([85, 80, 195])
    green_mask13 = cv2.inRange(hsv_image, lower_green13, upper_green13)

    lower_green14 = np.array([80, 105, 120])
    upper_green14 = np.array([90, 125, 130])
    green_mask14 = cv2.inRange(hsv_image, lower_green14, upper_green14)

    lower_green15 = np.array([25, 10, 140])
    upper_green15 = np.array([40, 80, 240])
    green_mask15 = cv2.inRange(hsv_image, lower_green15, upper_green15)

    lower_green16 = np.array([40, 35, 230])
    upper_green16 = np.array([45, 50, 250])
    green_mask16 = cv2.inRange(hsv_image, lower_green16, upper_green16)

    lower_green17 = np.array([50, 85, 65])
    upper_green17 = np.array([90, 230, 165])
    green_mask17 = cv2.inRange(hsv_image, lower_green17, upper_green17)

    lower_green18 = np.array([35, 85, 75])
    upper_green18 = np.array([50, 255, 220])
    green_mask18 = cv2.inRange(hsv_image, lower_green18, upper_green18)

    lower_green19 = np.array([35, 55, 160])
    upper_green19 = np.array([50, 175, 255])
    green_mask19 = cv2.inRange(hsv_image, lower_green19, upper_green19)

    lower_green20 = np.array([35, 175, 200])
    upper_green20 = np.array([40, 205, 240])
    green_mask20 = cv2.inRange(hsv_image, lower_green20, upper_green20)

    lower_green21 = np.array([50, 60, 155])
    upper_green21 = np.array([60, 120, 220])
    green_mask21 = cv2.inRange(hsv_image, lower_green21, upper_green21)

    lower_green22 = np.array([35, 185, 135])
    upper_green22 = np.array([45, 255, 255])
    green_mask22 = cv2.inRange(hsv_image, lower_green22, upper_green22)

    lower_green23 = np.array([60, 110, 35])
    upper_green23 = np.array([70, 150, 50])
    green_mask23 = cv2.inRange(hsv_image, lower_green23, upper_green23)

    lower_green24 = np.array([55, 165, 30])
    upper_green24 = np.array([65, 230, 45])
    green_mask24 = cv2.inRange(hsv_image, lower_green24, upper_green24)

    lower_green25 = np.array([60, 90, 35])
    upper_green25 = np.array([70, 210, 95])
    green_mask25 = cv2.inRange(hsv_image, lower_green25, upper_green25)

    green_mask = cv2.bitwise_or(green_mask, green_mask1)
    green_mask = cv2.bitwise_or(green_mask, green_mask2)
    green_mask = cv2.bitwise_or(green_mask, green_mask3)
    green_mask = cv2.bitwise_or(green_mask, green_mask4)
    green_mask = cv2.bitwise_or(green_mask, green_mask5)
    green_mask = cv2.bitwise_or(green_mask, green_mask7)
    green_mask = cv2.bitwise_or(green_mask, green_mask8)
    green_mask = cv2.bitwise_or(green_mask, green_mask9)
    green_mask = cv2.bitwise_or(green_mask, green_mask10)
    green_mask = cv2.bitwise_or(green_mask, green_mask11)
    green_mask = cv2.bitwise_or(green_mask, green_mask12)
    green_mask = cv2.bitwise_or(green_mask, green_mask13)
    green_mask = cv2.bitwise_or(green_mask, green_mask14)
    green_mask = cv2.bitwise_or(green_mask, green_mask15)
    green_mask = cv2.bitwise_or(green_mask, green_mask16)
    green_mask = cv2.bitwise_or(green_mask, green_mask17)
    green_mask = cv2.bitwise_or(green_mask, green_mask18)
    green_mask = cv2.bitwise_or(green_mask, green_mask19)
    green_mask = cv2.bitwise_or(green_mask, green_mask20)
    green_mask = cv2.bitwise_or(green_mask, green_mask21)
    green_mask = cv2.bitwise_or(green_mask, green_mask22)
    green_mask = cv2.bitwise_or(green_mask, green_mask23)
    green_mask = cv2.bitwise_or(green_mask, green_mask24)
    green_mask = cv2.bitwise_or(green_mask, green_mask25)

    # merge
    mask = cv2.bitwise_and(mask, ~green_mask)
    extracted_image = cv2.bitwise_and(img, img, mask=mask)
    # bgr to rgb
    extracted_image = cv2.cvtColor(extracted_image, cv2.COLOR_BGR2RGB)
    return extracted_image

def rgb_tagging(enhanced_img):
    """Tag the RGB image

    Args:
        enhanced_img (cv2RGBimg, 360*480*3): enhanced RGB image
    """
    ### RGB quality assessment
    # Calculate the proportion of pixel points in the upper 3/4 and middle 1/3 of the RGB image
    # Define the area to be evaluated
    roi = enhanced_img[0:int(3/4*SHAPE[0]), int(SHAPE[1]/3):int(2*SHAPE[1]/3)]
    # Convert to grayscale
    roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
    # Total number of pixels
    area_total = roi.shape[0] * roi.shape[1]
    # Count valid pixels
    area_valid = np.count_nonzero(roi)
    # Calculate the ratio
    rgb_percent = area_valid / area_total
    return rgb_percent

def depth_tagging(enhanced_img, depth_img):
    ### Depth quality assessment
    rgb_roi = enhanced_img.copy()
    rgb_roi[:, 0:int(SHAPE[1]/3)] = 0
    rgb_roi[:, int(SHAPE[1]*2/3):] = 0
    # Convert to binary image
    _, rgb_roi = cv2.threshold(rgb_roi, 0, 255, cv2.THRESH_BINARY)
    rgb_roi = rgb_roi[:, :, 0]
    # Dilate by 5 pixels
    rgb_roi = cv2.dilate(rgb_roi, np.ones((5, 5), np.uint8), iterations=1)
    # Extract depth values from the area of depth_img corresponding to rgb_roi
    depth_values = depth_img[rgb_roi > 0]
    # Binning
    bins = np.arange(np.min(depth_values), np.max(depth_values), 0.03)
    digitized_center_depths = np.digitize(depth_values, bins)
    mode_depth = bins[stats.mode(digitized_center_depths, axis=None).mode][0]

    # Zero out depth values that are not within 10% of the mode center depth
    depth_approx = 0.1 * mode_depth
    depth_filtered = depth_img.copy()
    # For those pixels that are not within 10% of the mode center depth, set them to 0
    depth_filtered[np.abs(depth_filtered - mode_depth) > depth_approx] = 0
    # Calculate the valid area in the middle third and the side areas of the filtered depth image
    middle_area_valid = np.count_nonzero(depth_filtered[:, int(SHAPE[1]/3):int(2*SHAPE[1]/3)])
    side_area_valid = np.count_nonzero(depth_filtered[:, 0:int(SHAPE[1]/3)]) + np.count_nonzero(depth_filtered[:, int(2*SHAPE[1]/3):])
    if side_area_valid != 0:
        middle_side_ratio = middle_area_valid / side_area_valid
        return middle_side_ratio
    else:
        return 999

def denoise(img):
    """To denoise the RGB or depth image

    Args:
        img (RGB or depth image): RGB or depth image

    Returns:
        img (RGB or depth image): RGB or depth image
    """
    # label each pixel by connected component of image
    # The 0th label will contain background pixels (pixels with depth value 0)
    labeled = measure.label(img > 0, connectivity=1, background=0)
    labels, counts = np.unique(labeled, return_counts=True)

    # Zero out points in tiny connected components (fewer than ALPHA pixels)
    # tiny = labels_target[np.where(counts[labels_target] < ALPHA)]
    tiny = labels[np.where(counts[labels] < ALPHA)]
    img[np.isin(labeled, tiny)] = 0.0

    # If the remaining components are not sufficiently "dense" to likely represent
    # a tree trunk, remove them  until they are.

    # Relabel.
    labeled = measure.label(img > 0, connectivity=1, background=0)
    labels, counts = np.unique(labeled, return_counts=True)

    # Omit the background.
    if labels[0] == 0:
        labels = labels[1:]
        counts = counts[1:]

    # If there was only background left, this is a bad image
    #     if len(labels) == 0:
    #         # raise NoTrunkFoundError
    #         print("NoTrunkFound")

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
        hull = spatial.ConvexHull(np.argwhere(img > 0))
        hull_density = inlier_area / hull.volume
        if hull_density > BETA:
            return img
        else:
            # If not, remove the component whose x-mean is furhest from the target component
            remove = sorted_labels[i]
            img[labeled == remove] = 0.0
            labeled[labeled == remove] = 0
            inlier_area = inlier_area - counts[remove - 1]

    return img

def read_depthtxt(depth_path):
    """Read the depth image from raw .txt file

    Args:
        depth_path (str): raw depth text file path

    Returns:
        depth_img(ndarray with 2 dimensions,eg.[360,480]): depth image
    """
    # Read from raw .txt file
    depth_img = np.loadtxt(depth_path, delimiter=",", usecols=range(0, 3))
    depth_img = depth_img[:, 2].reshape(120, 160)
    height, width = depth_img.shape
    # Scale the size to (360,480)
    new_height = 360
    new_width = 480
    depth_img = cv2.resize(depth_img, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    return depth_img

def calculate_kandb(line):
    """Calculate the slope and intercept of a line.
    line: (x1, y1, x2, y2)
    """
    # Assuming the formula of the line is x = my + b
    x1, y1, x2, y2 = line
    slope = (x2 - x1) / (y2 - y1 + 1e-10)  # Adding a small number to avoid division by zero
    intercept = x1 - slope * y1
    return slope, intercept

def get_extend_line(slope, intercept):
    """Get the coordinates of two points (x1, y1, x2, y2) on the extended line.
    Assuming the line extends from the left boundary to the right boundary.
    """
    # Determining the two new endpoints of the extended portion of the line
    new_x1 = int(intercept)
    new_y1 = 0
    new_x2 = int(slope * SHAPE[0] + intercept)
    new_y2 = SHAPE[0]
    return new_x1, new_y1, new_x2, new_y2

def filter_depth_img(depth, binary_mask):
    """Filter the depth image to retain the trunk part

    Args:
        depth (ndarray with 2 dimensions,eg.[360,480]): depth image
        binary_mask(ndarray with 2 dimensions,eg.[360,480]): binary mask
    Returns:
        depth_filtered(ndarray with 2 dimensions,eg.[360,480]): filetered depth image
    """
    ######### Calculate the mode depth #########
    # Rule out the lower left and lower right corners(usually ground)
    h, w = SHAPE
    # Create a mask with lower left and lower right corners
    mask_corner = np.zeros((h, w), dtype=np.uint8)
    mask_corner[2*h//3:, :w//3] = 255 # lower left
    mask_corner[2*h//3:, 2*w//3:] = 255 # lower right
    binary_mask_remove_corner = cv2.bitwise_and(binary_mask, binary_mask, mask=~mask_corner)

    # Open to denoise
    kernel = np.ones((4,4),np.uint8)
    mask = cv2.morphologyEx(binary_mask_remove_corner, cv2.MORPH_OPEN, kernel)

    # Close to fill the holes
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

    # Expand the image so that the mask can include as many trunk as possible
    kernel = np.ones((20,20), np.uint8)
    dilated_mask = cv2.dilate(mask, kernel, iterations=1)

    # Denoise
    # mask = denoise(mask)

    # filtered rgb-d image
    masked_depth_image = depth.copy()
    masked_depth_image[mask == 0] = 0
    # Center third part of the image
    masked_depth_image = masked_depth_image[:, w//3:2*w//3]

    # For now try 3cm resolution
    bins = np.arange(np.min(masked_depth_image), np.max(masked_depth_image), 0.03)
    digitized_center_depths = np.digitize(masked_depth_image[masked_depth_image != 0], bins)
    mode_depth = bins[stats.mode(digitized_center_depths, axis=None).mode][0]
    #############################################

    # zero out depth values that are not within 10% of the mode center depth
    depth_approx = 0.1 * mode_depth
    dilate_masked_depth_image = depth.copy()
    dilate_masked_depth_image[dilated_mask == 0] = 0

    depth_filtered = dilate_masked_depth_image
    depth_filtered = np.array(depth_filtered)
    # For those pixels that are not within 10% of the mode center depth, set them to 5m(very far away)
    depth_filtered[np.abs(dilate_masked_depth_image - mode_depth) > depth_approx] = 5
    return depth_filtered

def denoise_rgb_suppress_and_enhance(rgb_suppress_and_enhance, rgb_quality_ratio):
    # Add two vertical lines at 1/3 and 2/3 of the image width
    img = rgb_suppress_and_enhance.copy()
    w = img.shape[1]
    img[:, int(w//3), :] = 0
    img[:, int(2*w//3), :] = 0
    # Label each pixel by connected component of image
    # The 0th label will contain background pixels (pixels with depth value 0)
    labeled = measure.label(img[:, :, 0] > 0, connectivity=1, background=0)
    labels, counts = np.unique(labeled, return_counts=True)

    labeled_middle = measure.label(img[:, int(w//3):int(2*w//3), 0] > 0, connectivity=1, background=0)
    labels_middle, counts_middle = np.unique(labeled_middle, return_counts=True)
    # Zero out points in tiny connected components (fewer than ALPHA pixels)
    # Segment-wise exclusion of small pixels
    tiny = labels[np.where(counts[labels] < ALPHA)]
    # Decide on quality, use different thresholds
    if rgb_quality_ratio <= 0.2:
        alpha_middle = ALPHA_MIDDLE_POOR
    else:
        alpha_middle = ALPHA
    nontiny_middle = labels_middle[np.where((counts_middle[labels_middle] > alpha_middle) & (counts_middle[labels_middle] < ALPHA))]
    A = np.isin(labeled, tiny)
    A = A.astype(int)
    B = np.isin(labeled_middle, nontiny_middle)
    B = np.pad(B, ((0, 0), (160, 160)), 'constant', constant_values=0)
    B = B.astype(int)
    tiny_final = cv2.bitwise_xor(A, B)
    tiny_final = tiny_final.astype(bool)

    img[tiny_final] = 0.0
    # Convert back to RGB
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    # Open to denoise
    kernel = np.ones((2, 2), np.uint8)
    img = cv2.morphologyEx(img, cv2.MORPH_OPEN, kernel)
    # Close to fill the holes
    img = cv2.morphologyEx(img, cv2.MORPH_CLOSE, kernel)
    return img

def get_hull_img_and_mask(denoised_rgb):
    img = denoised_rgb.copy()
    h,w = img.shape[:2]
    img[:,int(w//3),:] = 0
    img[:,int(2*w//3),:] = 0
    labeled = measure.label(img[:,:,0] > 0, connectivity=1, background=0)
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
    # target_component = labels[np.argmax(counts)]
    ######################### modify #########################
    labeled_middle = measure.label(img[:, int(w//3):int(2*w//3),0]>0, connectivity=1, background=0)
    labels_middle, counts_middle = np.unique(labeled_middle, return_counts=True)
    # Omit the background.
    if labels_middle[0] == 0:
        labels_middle = labels_middle[1:]
        counts_middle = counts_middle[1:]
    if len(labels_middle) == 0:
        raise NoTrunkFoundError
    target_component = labels[np.where(counts == np.max(counts_middle, axis=0))[0][0]]
    ########################################################
    target_mean = means[target_component - 1]
    diff_from_target = np.abs(means - target_mean)
    sorted_inds = diff_from_target.argsort()
    sorted_labels = labels[sorted_inds]
    inlier_area = np.max(counts_middle, axis=0)
    hull_img = np.zeros_like(img)
    hull_img[labeled == sorted_labels[0]] = img[labeled == sorted_labels[0]]
    coords = np.argwhere(hull_img[:,:,0] > 0)
    hull = spatial.ConvexHull(coords)
    # hull_density = inlier_area / hull.volume
    vertices = hull.vertices
    points = coords[vertices].astype(np.int32)
    points[:, [1, 0]] = points[:, [0, 1]]
    # calculate the average y-coordinate (height)
    average_height = np.mean(coords[:, 0])
    for i in range(1,len(sorted_labels)-1):  # Must keep at least one component
        # Check that the convex hull of the components is sufficiently dense in trunk inliers
        # by examining the ratio of the pixel area in remaining components
        # to the total area of the convex hull
        # ConvexHull computed using http://www.qhull.org/
        # if (hull.volume > 1/2*h*w) | ((np.ptp(points[:,0])>1/3*w) & (np.ptp(points[:,1])>2/3*h)):
        # if hull.volume > 1/2*h*w:
        if (hull.volume > 0.4*h*w) | ((np.ptp(points[:,0])>1/3*w) & (average_height < 1/2*h)):
            break
        else:
            # If not, add the component whose x-mean is nearest to the target component
            add = sorted_labels[i]
            hull_img[labeled == add] = img[labeled == add]
            inlier_area = inlier_area + counts[add - 1]
            coords = np.argwhere(hull_img[:,:,0] > 0)
            hull = spatial.ConvexHull(coords)
            vertices = hull.vertices
            points = coords[vertices].astype(np.int32)
            points[:, [1, 0]] = points[:, [0, 1]]
            average_height = np.mean(coords[:, 0])
    # generate while background mask
    mask = np.zeros_like(img[:,:,0])
    if hull.volume < 10000:
        # Generate a middle third mask
        mask[:, int(w//3):int(2*w//3)] = 255
    else:
        cv2.fillPoly(mask, [points], 255)
    return hull_img, mask

def filter_depth_img_with_centralpixel(depth, rgb_hull_img):
    """Filter the depth image to retain the trunk part."""
    depth_img = depth.copy()
    # Set depth values greater than 5m to 0, assuming values are in meters
    depth_img[depth_img > 5] = 0
    # Read the RGB image
    rgb_img = rgb_hull_img.copy()
    middle = 240  # Assuming the middle column index for a standard 480-width image
    middle_ten = np.arange(middle-2, middle+2)  # Select a small window around the central column
    middle_ten = middle_ten.tolist()
    # Extract the pixel values from the central column
    mid_vals = [depth_img[180, int(c)] for c in middle_ten]  # Assuming 180 is the middle row for a standard 360-height image
    # Calculate the average of these central pixel values
    mode_depth = np.mean(mid_vals)
    # Zero out depth values that are not within 20% of the mode center depth
    depth_approx = 0.2 * mode_depth
    depth_filtered = depth_img.copy()
    # Apply mask based on the RGB image's first channel to retain trunk area
    depth_filtered[rgb_img[:, :, 0] == 0] = 0
    # For those pixels not within 20% of the mode center depth, set them to 10m (assuming far away)
    depth_filtered[np.abs(depth_filtered - mode_depth) > depth_approx] = 10
    # Normalize to 0-255 for visualization
    depth_filtered = (depth_filtered - depth_filtered.min()) / (depth_filtered.max() - depth_filtered.min()) * 255
    return depth_filtered

def edge_detection(prediction):
    # perform Canny edge detection
    pre_img = prediction.copy()
    pre_img = pre_img.astype(np.uint8)
    edges = cv2.Canny(pre_img, threshold1=50, threshold2=150)
    return edges

def find_best_parallel_line(edges, rgb_quality_ratio):
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, threshold=30, minLineLength=30, maxLineGap=50)
    # Skip if lines are None:
    if lines is None:
        raise ParallelLineNotFoundError
    # Initialize the sum of minimum distances and corresponding parallel line endpoints
    best_parallel_lines = []
    # First, exclude all lines that are too slanted (horizontal angle less than 30 degrees)
    for line in lines:
        x1, y1, x2, y2 = line[0]
        angle = np.abs(np.arctan2(y2 - y1, x2 - x1))
        if np.abs(angle) < np.pi / 5:
            rows = np.where((lines == line).all(axis=2))[0]
            # Delete by index
            lines = np.delete(lines, rows, axis=0)
    # Define the threshold for the shortest distance
    min_dist = 10 if rgb_quality_ratio <= 0.2 else 20
    for line1 in lines:
        x1, y1, x2, y2 = line1[0]
        for line2 in lines:
            x3, y3, x4, y4 = line2[0]
            if not np.array_equal(line1[0], line2[0]):
                # Consider them parallel if the angle difference is within a certain range
                angle_diff = np.abs(np.arctan2(y2 - y1, x2 - x1) - np.arctan2(y4 - y3, x4 - x3))
                if np.abs(angle_diff) < np.pi/16 or np.abs(angle_diff-np.pi) < np.pi/16:
                    # Exclude cases where two lines intersect
                    k1, b1 = calculate_kandb(line1[0])
                    k2, b2 = calculate_kandb(line2[0])
                    intersection_y = (b2 - b1) / (k1 - k2 + 1e-10)
                    intersection_x = k1 * intersection_y + b1
                    if 0 <= intersection_x < SHAPE[1] and 0 <= intersection_y < SHAPE[0]:
                        continue
                    # Exclude if the distance between the lines at the top and bottom of the image is less than a threshold
                    new_x1, new_y1, new_x2, new_y2 = get_extend_line(k1, b1)
                    new_x3, new_y3, new_x4, new_y4 = get_extend_line(k2, b2)
                    if np.abs(new_x1 - new_x3) < min_dist or np.abs(new_x2 - new_x4) < min_dist:
                        continue
                    # Add to best_parallel_lines if conditions are met
                    best_parallel_lines.append([(x1, y1, x2, y2), (x3, y3, x4, y4)])
    # Remove duplicate combinations of parallel lines
    best_parallel_lines = list(set(tuple(sorted(item)) for item in best_parallel_lines))
    if not best_parallel_lines:
        raise ParallelLineNotFoundError
    sum_distance_list = []
    for line_pair in best_parallel_lines:
        # Calculate the sum of distances in y-direction for each pair of lines
        disty = np.abs(line_pair[0][1] - line_pair[0][3]) + np.abs(line_pair[1][1] - line_pair[1][3])
        sum_distance_list.append(disty)
    # Select the pair of lines with the maximum distance
    line_draw = best_parallel_lines[sum_distance_list.index(max(sum_distance_list))]
    return line_draw

def get_two_cross_distance(k1, k2, b1, b2, y0):
    # Calculate the distance between the intersection points of a perpendicular line and two boundary lines
    # y0 is the y-coordinate of the perpendicular line
    y1 = (k1 + k2) / (k1 * (k1 + k2) + 2) * (((k1 + k2) / 2 + 2 / (k1 + k2 + 1e-8)) * y0 + (b2 - b1) / 2)
    x1 = k1 * y1 + b1
    y2 = (k1 + k2) / (k2 * (k1 + k2) + 2) * (((k1 + k2) / 2 + 2 / (k1 + k2 + 1e-8)) * y0 + (b1 - b2) / 2)
    x2 = k2 * y2 + b2
    dist = np.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2)
    return dist

def extract_largest_component(img):
    # If img is multi-channel, take the first channel
    if len(img.shape) > 2:
        img = img[:, :, 0]
    # Label connected components
    labeled_image, num_features = measure.label(img, connectivity=2, return_num=True)

    # Calculate the area of each connected domain
    region_props = measure.regionprops(labeled_image)
    areas = [prop.area for prop in region_props]

    # Find the label of the largest connected domain
    max_area_label = np.argmax(areas) + 1  # Note: labels start from 1

    # Create a blank image and extract the largest connected domain
    largest_component = (labeled_image == max_area_label)
    # Convert to integer type
    largest_component = largest_component.astype(np.uint8)
    return largest_component

def fit_line(best_lines, edges):
    h, w = 360, 480
    line_draw = best_lines
    slope1, intercept1 = calculate_kandb(line_draw[0])
    slope2, intercept2 = calculate_kandb(line_draw[1])
    # Get drawing points for the extended line
    new_x1, new_y1, new_x2, new_y2 = get_extend_line(slope1, intercept1)
    new_x3, new_y3, new_x4, new_y4 = get_extend_line(slope2, intercept2)
    # Draw lines from the new endpoints to the image boundary
    # Create a 360 x 480 x 3 array of zeros
    canvas = np.zeros((h, w, 3), dtype=np.uint8)
    cv2.line(canvas, (new_x1, new_y1), (new_x2, new_y2), (255, 255, 255), 2)
    cv2.line(canvas, (new_x3, new_y3), (new_x4, new_y4), (255, 255, 255), 2)
    # Draw all the lines
    # Dilate the canvas
    kernel = np.ones((10, 10), np.uint8)
    canvas = cv2.dilate(canvas, kernel, iterations=1)
    # Calculate the average column value for each row of canvas
    row_means = np.zeros(h)
    for i in range(h):
        cols = np.where(canvas[i] > 0)[0]
        row_means[i] = cols.mean()
    # Round row_means to integers
    row_means = row_means.astype(int)
    for line in line_draw:
        x1, y1, x2, y2 = line
        cv2.line(canvas, (x1, y1), (x2, y2), (255, 255, 255), 2)
    # Extract edge from canvas
    # Convert edge to three channels
    edges_copy = edges.copy()
    edges_copy = cv2.cvtColor(edges_copy, cv2.COLOR_GRAY2BGR)
    canvas = cv2.bitwise_and(canvas, edges_copy)

    left = np.zeros_like(canvas)
    right = np.zeros_like(canvas)

    for i in range(canvas.shape[0]):
        scanner = np.where(canvas[i, :] != 0)
        # If scanner is not empty
        if scanner[0].size != 0:
            left_idx = scanner[0][0]
            right_idx = scanner[0][-1]
            if left_idx < row_means[i]:
                left[i, left_idx] = canvas[i, left_idx]
            if right_idx > row_means[i]:
                right[i, right_idx] = canvas[i, right_idx]
    # Dilate left and right then extract the largest component
    kernel = np.ones((15, 15), np.uint8)
    left = cv2.dilate(left, kernel, iterations=1)
    right = cv2.dilate(right, kernel, iterations=1)
    left = extract_largest_component(left)
    right = extract_largest_component(right)
    # Convert to integer type
    left = left.astype(np.uint8)
    right = right.astype(np.uint8)
    # Erode
    kernel = np.ones((14, 14), np.uint8)
    left = cv2.erode(left, kernel, iterations=1)
    right = cv2.erode(right, kernel, iterations=1)
    # First draw the left side
    coords = np.argwhere(left)
    # Swap the order of two columns
    coords[:, [0, 1]] = coords[:, [1, 0]]
    pixel_coords = [tuple(coord) for coord in coords]
    # Fit a line to the points, getting the equation of the line
    x = []
    y = []
    for i in range(len(pixel_coords)):
        x.append(pixel_coords[i][0])
        y.append(pixel_coords[i][1])
    # Use numpy's polyfit function to fit a line and get the equation
    z1 = np.polyfit(y, x, 1)
    # Use numpy's poly1d function to create the equation
    p1 = np.poly1d(z1)
    # Generate points on the y-axis
    y_axis = np.linspace(0, 359, 360)
    # Generate points on the x-axis
    x_axis = p1(y_axis)
    # Convert floating-point numbers in x_axis and y_axis to integers
    x_axis = x_axis.astype(int)
    y_axis = y_axis.astype(int)
    # Combine points in x_axis and y_axis into tuples, stored in points2
    points1 = []
    for i in range(len(x_axis)):
        points1.append((x_axis[i], y_axis[i]))
    # Draw right line
    coords = np.argwhere(right)
    # Swap the order of two columns
    coords[:, [0, 1]] = coords[:, [1, 0]]
    pixel_coords = [tuple(coord) for coord in coords]
    # Fit a line to the points, getting the equation of the line
    # Extract x and y from each tuple in points and store them separately in x and y
    x = []
    y = []
    for i in range(len(pixel_coords)):
        x.append(pixel_coords[i][0])
        y.append(pixel_coords[i][1])
    # Use numpy's polyfit function to fit a line and get the equation
    z1 = np.polyfit(y, x, 1)
    # Use numpy's poly1d function to generate the equation
    p1 = np.poly1d(z1)
    # Generate points on the y-axis
    y_axis = np.linspace(0, 359, 360)
    # Generate points on the x-axis
    x_axis = p1(y_axis)
    # Convert floating-point numbers in x_axis and y_axis to integers
    x_axis = x_axis.astype(int)
    y_axis = y_axis.astype(int)
    # Combine points in x_axis and y_axis into tuples, stored in points2
    points2 = []
    for i in range(len(x_axis)):
        points2.append((x_axis[i], y_axis[i]))
    # Draw lines from points2
    # Merge and draw the two lines
    canvas = np.zeros_like(left, dtype=np.uint8)
    # First, remove points with negative values from points1 and points2
    points1 = np.array(points1)
    points2 = np.array(points2)
    points1 = points1[points1[:, 0] >= 0]
    points2 = points2[points2[:, 0] >= 0]
    for i in range(len(points1)):
        if (points1[i][1] < 360) & (points1[i][0] < 480):
            canvas[points1[i][1], points1[i][0]] = 255
    for i in range(len(points2)):
        if (points2[i][1] < 360) & (points2[i][0] < 480):
            canvas[points2[i][1], points2[i][0]] = 255
    # Save metadata of left and right lines in a JSON file, coordinates in cv2 format
    line_info = {
        "left_line": {
            "top_yx": [int(points1[0][0]), int(points1[0][1])],
            "bottom_yx": [int(points1[-1][0]), int(points1[-1][1])]
        },
        "right_line": {
            "top_yx": [int(points2[0][0]), int(points2[0][1])],
            "bottom_yx": [int(points2[-1][0]), int(points2[-1][1])]
        }
    }
    line_info = json.dumps(line_info)
    # Dilate by two pixels to make the lines thicker
    kernel = np.ones((2, 2), np.uint8)
    canvas = cv2.dilate(canvas, kernel, iterations=1)
    # Convert to three channels
    canvas = cv2.cvtColor(canvas, cv2.COLOR_GRAY2BGR)
    return canvas, line_info

def calculate_DBH(depth, best_lines):
    ### Calculate DBH ###
    new_height = 360
    depth_txt = depth.copy()
    # Calculate the X coordinates of the two lines at the center of the image
    slope1, intercept1 = calculate_kandb(best_lines[0])
    slope2, intercept2 = calculate_kandb(best_lines[1])
    left = slope1 * (new_height // 2) + intercept1
    right = slope2 * (new_height // 2) + intercept2
    # Calculate the average pixel length
    dm = get_two_cross_distance(slope1, slope2, intercept1, intercept2, new_height // 2)
    dm_up = get_two_cross_distance(slope1, slope2, intercept1, intercept2, new_height // 6)
    dm_down = get_two_cross_distance(slope1, slope2, intercept1, intercept2, new_height // 6 * 5)
    dm_average = (dm_up + dm_down + dm) / 3
    # Select the middle five values from the list formed by the boundaries left and right
    # Calculate the median
    middle = (left + right) // 2
    # Generate a sequence
    middle_ten = np.arange(middle - 2, middle + 2)
    middle_ten = middle_ten.tolist()
    # Extract the pixel values from the middle column
    mid_vals = [depth_txt[new_height // 2, int(c)] for c in middle_ten]
    # Calculate the average
    mode_depth = np.mean(mid_vals)
    # Calculate the diameter
    GAMMA = 356.25
    D = mode_depth / (GAMMA / dm_average - np.sqrt(0.25 - 25 / dm_average ** 2))
    return D

def find_one_point_three_meter(depth, device_height):
    ### Use depth to find the 1.3m position ###
    GAMMA = 356.25
    delta_h_depth = depth.copy()
    # Divide by GAMMA to get the actual height represented by each pixel in the depth image
    delta_h_depth = delta_h_depth / GAMMA
    central_pixel_height = device_height
    # Initialize the starting point for search
    move_point = [180, 240]  # Assuming the format [row, column]
    # Determine the relationship between central_pixel_height and 1.3m
    # If central_pixel_height < 1.3m, search upwards in the image
    if central_pixel_height < 1.3:
        move_direction = 1  # Move upwards
    else:
        move_direction = -1  # Move downwards
    move_range = [-1, 0, 1]  # Search range for the next point
    height = central_pixel_height
    while np.abs(height - 1.3) > 0.01:  # Until the height is approximately 1.3m
        # Find the actual height of three pixels above the central_pixel, find the point closest to move_point in depth
        delta_depth_list = []
        for i in move_range:
            delta_depth = np.abs(depth[move_point[0] - i, move_point[1]] - depth[move_point[0], move_point[1]])
            delta_depth_list.append(delta_depth)
        # Find the index of the minimum delta_depth in delta_depth_list
        min_index = delta_depth_list.index(min(delta_depth_list))
        # Update move_point
        move_point[0] = move_point[0] - move_direction
        move_point[1] = move_point[1] + move_range[min_index]
        # Update height
        height += delta_h_depth[move_point[0], move_point[1]] * move_direction
        # Set the delta_h_depth at move_point to 0.2 for visualization (or marking), *seems like a typo, adjusted to 0.1 as per the comment
        delta_h_depth[move_point[0], move_point[1]] = 0.1
    # Swap x and y coordinates for move_point
    move_point[0], move_point[1] = move_point[1], move_point[0]
    return move_point

def calculate_ratio_inside_box(extract_img):
    # Calculate the number of pixels within a 30*30 square
    count = 0
    rgb_width = 480
    rgb_height = 360
    for i in range(rgb_width//2-15, rgb_width//2+15):
        for j in range(rgb_height//2-15, rgb_height//2+15):
            if extract_img[j][i][0] != 0:
                count += 1
    # Calculate the ratio of pixels within the square
    return count / (30 * 30)

def fuse_line_with_bgr(canvans_with_lines,bgr):
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    fuse_img = cv2.addWeighted(canvans_with_lines, 1, rgb, 1, 0)
    return fuse_img