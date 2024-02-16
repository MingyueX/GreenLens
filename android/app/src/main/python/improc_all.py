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

sys.path.append('./src')
sys.path.append('./models')

from src.imageprocessor import *

# global model, transform, depths_transform
global rgb_quality_ratio, depth, bgr


def preprocess_images(depth_arr, rgb_arr, depth_width, depth_height):
    global rgb_quality_ratio,depth, bgr

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
    # depth_quality_ratio = depth_tagging(extract_img,depth)
    # denoise rgb
    denoised_rgb = denoise_rgb_suppress_and_enhance(extract_img, rgb_quality_ratio)
    # get hull image and mask
    hull_img, hull_mask = get_hull_img_and_mask(denoised_rgb)
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

def run(output_array, gt_width, gt_height):
    global rgb_quality_ratio,depth, bgr

    res = torch.tensor(output_array).reshape(1, 1, 352, 352)

    res = F.upsample(res, size=(gt_height, gt_width), mode='bilinear', align_corners=False)
    res = res.sigmoid().data.cpu().numpy().squeeze()
    res = (res - res.min()) / (res.max() - res.min() + 1e-8)
    res = res * 255
    ######## Inference over ########

    # get edge image
    edges = edge_detection(res)
    # find the best parallel pair
    best_lines = find_best_parallel_line(edges, rgb_quality_ratio)
    # get the trunk boundary image
    canvans_with_lines, line_json = fit_line(best_lines, edges)
    # DBH calculation
    pre_DBH = calculate_DBH(depth,best_lines)
    # print(pre_DBH)

    # fuse the lines with the bgr
    fuse_img = fuse_line_with_bgr(canvans_with_lines,bgr)

    # convert the image to base64
    img_base64 = numpy_array_to_base64(fuse_img)

    result = {
        "img": img_base64,
        "pre_DBH": pre_DBH,
        "line_json": line_json
    }
    result_json = json.dumps(result)
    return result_json
    # return img_base64, pre_DBH


def numpy_array_to_base64(img_array):
    # Convert numpy array to image
    _, buffer = cv2.imencode('.png', img_array)
    img_str = base64.b64encode(buffer).decode('utf-8')
    return img_str
