import cv2
import sys
import io
import numpy as np
sys.path.append('./src')
from src.imageprocessor import *

def get_ratio_inside_box(rgb_arr):
    # ######  DIY  #####
    # test_num = 24
    # with open(f"E:/Codes/PythonFiles/Projects/tree-segmentation-main-7.10/data/all/Frank's/rgb_jpg/{test_num}.jpg", 'rb') as image_file:
    #     rgb_arr = image_file.read()
    # ###################
    new_width = 480
    new_height = 360
    # Read RGB image and resize
    io_buf = io.BytesIO(rgb_arr)
    # read as BGR
    bgr = cv2.imdecode(np.frombuffer(io_buf.getbuffer(), dtype=np.uint8), -1)
    # resize the image to 360x480
    bgr = cv2.resize(bgr, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    # suppress green and extract brown
    extract_img = suppress_and_enhance(bgr)
    valid_ratio = calculate_ratio_inside_box(extract_img)
    return valid_ratio

#valid_ratio分为三个等级，小于0.5,0.5-0.75,大于0.75