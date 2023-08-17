import io
import numpy as np
# from skimage import io as skio
# from skimage import img_as_ubyte, img_as_float, transform
from scipy import ndimage
from scipy.ndimage import interpolation
import matplotlib.pyplot as plt
import sys
sys.path.append('./src')
from src.imageprocessor import *

def run(depth_arr, rgb_arr, rgb_width, rgb_height, depth_width, depth_height):
    
    # Read depth image and resize as if we were going to call processor.py
    TOF_SHAPE = (depth_height, depth_width)
    depth = np.array(depth_arr, dtype=np.float64).reshape(TOF_SHAPE)
    ### convert the depth image to 360x480
    new_height = 360
    new_width = 480
    depth = cv2.resize(depth, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    ##############################

    # Read RGB image and resize
    io_buf = io.BytesIO(rgb_arr)
    # read as BGR
    img_cv2 = cv2.imdecode(np.frombuffer(io_buf.getbuffer(), dtype=np.uint8), -1)
    # resize the image to 360x480
    img_cv2 = cv2.resize(img_cv2, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    extract_img = suppress_and_enhance(img_cv2)
    rgb_ratio = rgb_tagging(extract_img)
    depth_ratio = depth_tagging(extract_img,depth)
    
    return depth_ratio
