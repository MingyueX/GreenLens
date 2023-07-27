import io
import os
import numpy as np
from skimage import io as skio
from skimage import img_as_ubyte, img_as_float, transform
from scipy import ndimage
from scipy.ndimage import interpolation
import matplotlib.pyplot as plt
import json
import base64

import processor
import model

def run(depth_arr, rgb_arr, rgb_width, rgb_height, depth_width, depth_height):

    TOF_SHAPE = (depth_height, depth_width)
    RGB_SHAPE = (rgb_height, rgb_width)

    # print(f"TOF_SHAPE: {TOF_SHAPE}")
    # print(f"RGB_SHAPE: {RGB_SHAPE}")

    # Read depth image and resize as if we were going to call processor.py
    depth = np.array(depth_arr, dtype=np.float64).reshape(TOF_SHAPE)
    log_info = f"Depth array shape: {depth.shape}\n"
    log_info += f"Maximum value in depth array: {np.max(depth)}\n"

    # rgb = np.reshape(skio.imread(io.BytesIO(rgb_arr)), (*RGB_SHAPE, 3)) # check if it works
    # scale_factor = 2
    # depth = np.kron(depth, np.ones((scale_factor, scale_factor)))

    rgb = transform.resize(skio.imread(io.BytesIO(rgb_arr)), RGB_SHAPE)

    preds = model.run(depth) # preds is (128, 160)
    preds = np.squeeze(preds)
    mask = transform.resize(preds, TOF_SHAPE)
    masked_depth = np.where(mask==0, 0, depth)
    masked_depth_resized = transform.resize(masked_depth, RGB_SHAPE)

    angle, left, right, est_depth, est_width, processor_log_info = processor.process(masked_depth_resized, rgb)

    log_info += processor_log_info

    log_info += f"Processed angle: {angle}, left: {left}, right: {right}\n"

	# Prepare display image
    bounds = np.zeros(RGB_SHAPE)
    bounds[:,left] = 1
    bounds[:,right] = 1
    bounds_rot = interpolation.rotate(bounds, -angle, reshape=False)
    ## bounds_rot = ndimage.rotate(bounds, -angle, reshape=False)
    rgb_disp = np.append(rgb, masked_depth_resized[:,:,np.newaxis], axis=2)

    rgb_disp_norm = (rgb_disp - np.min(rgb_disp)) / (np.max(rgb_disp) - np.min(rgb_disp))
    ## rgb_disp = np.clip(rgb_disp, -1, 1)

    rgb_disp_norm[np.where(np.abs(bounds_rot) > 0.1 )] = [0.0, 1.0, 0.0, 1.0]

    rgb_disp_norm_bytes = img_as_ubyte(rgb_disp_norm).tobytes()
    rgb_disp_norm_base64 = base64.b64encode(rgb_disp_norm_bytes).decode('utf-8')

    result = {
        "rgb_disp_norm": rgb_disp_norm_base64,
        "est_depth": est_depth,
        "est_width": est_width,
        "log_info": log_info
    }
    result_json = json.dumps(result)

    ## return bytes(img_as_ubyte(rgb_disp)), est_depth, est_width
    return result_json
