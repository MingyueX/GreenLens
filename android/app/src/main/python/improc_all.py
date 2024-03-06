import torch
import cv2
import sys
import io
import json
import base64
import numpy as np
from io import BytesIO
from PIL import Image
import torch.nn.functional as F
from PIL import Image
import torchvision.transforms as transforms

sys.path.append('./src')
sys.path.append('./models')

from src.imageprocessor import *

# global model, transform, depths_transform
global rgb_quality_ratio, depth, bgr, new_height, new_width


def preprocess_images(depth_arr, rgb_arr, depth_width, depth_height):
    global rgb_quality_ratio,depth, bgr, new_height, new_width

    TOF_SHAPE = (depth_height, depth_width)
    depth = np.array(list(depth_arr), dtype=np.float64).reshape(TOF_SHAPE)
    ### convert the depth image to 360x480
    new_height = 360
    new_width = 480
    depth = cv2.resize(depth, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    ##############################

    # Read RGB image and resize
    io_buf = io.BytesIO(rgb_arr)
    # read as BGR
    bgr = cv2.imdecode(np.frombuffer(io_buf.getbuffer(), dtype=np.uint8), -1)
    # resize the image to 360x480
    bgr = cv2.resize(bgr, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    # suppress green and extract brown
    extract_img = suppress_and_enhance(bgr)
    # get rgb and depth quality ratio
    rgb_quality_ratio = rgb_tagging(extract_img)
    # denoise rgb
    denoised_rgb = denoise_rgb_suppress_and_enhance(extract_img, rgb_quality_ratio)
    # get hull image and mask
    hull_img, _ = get_hull_img_and_mask(denoised_rgb)
    # filter depth image using modal depth within the hull image
    filter_depth_img = filter_depth_img_with_centralpixel(depth, hull_img)

    image_rgb = Image.fromarray(cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB))
    img_depth = Image.fromarray(filter_depth_img)
    img_depth = img_depth.convert('L')
    byte_array_rgb = image_to_byte_array(image_rgb)
    byte_array_depth = image_to_byte_array(img_depth)

    return byte_array_rgb, byte_array_depth

def image_to_byte_array(img):
    byte_io = BytesIO()
    img.save(byte_io, format='PNG')
    return byte_io.getvalue()

def run(output_array, gt_width, gt_height, GAMMA = 371.25):
    global rgb_quality_ratio,depth, bgr, new_height, new_width

    res = torch.tensor(output_array).reshape(1, 1, 352, 352)

    res = F.upsample(res, size=(gt_height, gt_width), mode='bilinear', align_corners=False)
    res = res.sigmoid().data.cpu().numpy().squeeze()
    res = (res - res.min()) / (res.max() - res.min() + 1e-8)
    res = res * 255
    ######## Inference over ########
    res = prediction_preprocess(res)
    # determine the boundary
    pca_angle = get_rotate_angle(res)
    res_rotated = rotate(res * 1, pca_angle, reshape=False)
    left_boundary, right_boundary = locate_boundary(res,pca_angle)
    # draw the boundary
    res_rotated[:,left_boundary] = 255
    res_rotated[:,right_boundary] = 255
    canvans_left,canvans_right = get_rotated_boundary_canvas(left_boundary,right_boundary,pca_angle)
    # get the boundary meta data
    boundary_meta_json = get_lines_meta(canvans_left, canvans_right)
    # DBH calculation
    t = GAMMA/(right_boundary-left_boundary)
    mid_vals = [depth[new_height//2, new_width//2-1], depth[new_height//2, new_width//2], depth[new_height//2, new_width//2+1]]
    mode_depth = np.mean(mid_vals)
    DBH = 2*mode_depth/((np.sqrt(1+4*t**2))-1)
    # fuse the image
    canvans_left = cv2.cvtColor(canvans_left, cv2.COLOR_GRAY2BGR)
    canvans_right = cv2.cvtColor(canvans_right, cv2.COLOR_GRAY2BGR)
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    result = cv2.addWeighted(canvans_right, 1, canvans_left, 1, 0)
    result = cv2.addWeighted(rgb, 1, result, 1, 0)
    # convert the image to base64
    img_base64 = numpy_array_to_base64(result)

    result = {
        "img": img_base64,
        "pre_DBH": DBH,
        "line_json": boundary_meta_json
    }
    result_json = json.dumps(result)
    return result_json
    # return img_base64, pre_DBH

def calculate_DBH_after_adjustment(depth_arr, m1, m2, n1, n2, GAMMA=371.25):
    """Calulate the DBH after adjustment

    Args:
        depth_arr (_type_): same as the return of np.loadtxt
        m, n (num): line 1: x=m1y+n1    line 2: x=m1y+n2
        GAMMA (float, optional): camera focal length. Defaults to 371.25.
    """
    # Since m1 and m2 are very close, we can take their average as m
    m = (m1 + m2) / 2
    distance = abs(n2 - n1) / ((1 + m**2) ** 0.5)
    t = GAMMA/distance
    depth = np.array(list(depth_arr), dtype=np.float64).reshape((120,160))
    # convert the depth image to 360x480
    new_height = 360
    new_width = 480
    depth = cv2.resize(depth, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    mid_vals = [depth[new_height//2, new_width//2-1], depth[new_height//2, new_width//2], depth[new_height//2, new_width//2+1]]
    # calculate the mean value
    mode_depth = np.mean(mid_vals)
    D = 2*mode_depth/((np.sqrt(1+4*t**2))-1)
    return D

def numpy_array_to_base64(img_array):
    # Convert numpy array to image
    _, buffer = cv2.imencode('.png', img_array)
    img_str = base64.b64encode(buffer).decode('utf-8')
    return img_str
