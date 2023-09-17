import cv2
import numpy as np
from skimage import measure
from scipy import spatial
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats
import os

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

    message = "Unable to find trunk in depth image"
    
class ParallelLineNotFoundError(Error):
    """Exception raised when no parallel line is found in the image."""

    message = "Unable to find parallel line in edge image"

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
    # 创建掩膜
    mask = np.zeros(hsv_image.shape[:2], dtype=np.uint8)
    # start_time = time.time()
    for h_range, s_range, v_range in zip(h_brown, s_brown, v_brown):
        lower = np.array([h_range[0], s_range[0], v_range[0]])
        upper = np.array([h_range[1], s_range[1], v_range[1]])
        mask1 = cv2.inRange(hsv_image, lower, upper)
        # mask_s = cv2.inRange(hsv_image[:, :, 1], s_min, s_max)
        # mask_v = cv2.inRange(hsv_image[:, :, 2], v_min, v_max)
        # mask_class = mask_h & mask_s & mask_v
        mask = cv2.bitwise_or(mask, mask1)
    extracted_image = cv2.bitwise_and(img, img, mask=mask)

    return extracted_image

# def suppress_and_enhance(img):
    """Suppress the green and enhance the brown in the image

    Args:
        img (ndarray with 3 dimensions,eg.[360,480,3]): RBG image

    Returns:
        result (ndarray with 3 dimensions,eg.[360,480,3]): RGB with brown enhancement
    """
    img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    ### Brown
    lower_brown = np.array([0, 0, 0])
    upper_brown = np.array([80, 255, 255])
    brown_mask = cv2.inRange(img, lower_brown, upper_brown)
    
    lower_brown1 = np.array([60, 0, 0])
    upper_brown1 = np.array([178, 255, 130])
    brown_mask1 = cv2.inRange(img, lower_brown1, upper_brown1)
    
    lower_brown2 = np.array([0, 0, 80])
    upper_brown2 = np.array([180, 125, 255])
    brown_mask2 = cv2.inRange(img, lower_brown2, upper_brown2)
    
    # Merge the brown masks
    brown_mask = cv2.bitwise_or(brown_mask, brown_mask1)
    brown_mask = cv2.bitwise_or(brown_mask, brown_mask2)
    
    
    ### Green
    lower_green = np.array([40, 120, 120])
    upper_green = np.array([50, 210, 185])
    # lower_green = np.array([5, 0, 20])
    # upper_green = np.array([180, 105, 180])
    green_mask = cv2.inRange(img, lower_green, upper_green)
    
    lower_green1 = np.array([90, 45, 150])
    upper_green1 = np.array([100, 80, 200])
    green_mask1 = cv2.inRange(img, lower_green1, upper_green1)

    lower_green2 = np.array([80, 105, 160])
    upper_green2 = np.array([90, 115, 170])
    green_mask2 = cv2.inRange(img, lower_green2, upper_green2)
    
    lower_green3 = np.array([60, 15, 65])
    upper_green3 = np.array([100, 110, 175])
    green_mask3 = cv2.inRange(img, lower_green3, upper_green3)
    
    lower_green4 = np.array([30, 0, 230])
    upper_green4 = np.array([40, 50, 255])
    green_mask4 = cv2.inRange(img, lower_green4, upper_green4)
    
    lower_green5 = np.array([80, 15, 180])
    upper_green5 = np.array([95, 35, 200])
    green_mask5 = cv2.inRange(img, lower_green5, upper_green5)
    
    lower_green6 = np.array([20, 65, 115])
    upper_green6 = np.array([35, 120, 190])
    green_mask6 = cv2.inRange(img, lower_green6, upper_green6)
    
    lower_green7 = np.array([45, 10, 200])
    upper_green7 = np.array([60, 55, 255])
    green_mask7 = cv2.inRange(img, lower_green7, upper_green7)
    
    lower_green8 = np.array([30, 60, 150])
    upper_green8 = np.array([35, 190, 255])
    green_mask8 = cv2.inRange(img, lower_green8, upper_green8)
    
    lower_green9 = np.array([80, 20, 180])
    upper_green9 = np.array([110, 35, 225])
    green_mask9 = cv2.inRange(img, lower_green9, upper_green9)
    
    lower_green10 = np.array([45, 30, 140])
    upper_green10 = np.array([75, 80, 205])
    green_mask10 = cv2.inRange(img, lower_green10, upper_green10)
    
    lower_green11 = np.array([55, 5, 180])
    upper_green11 = np.array([80, 70, 255])
    green_mask11 = cv2.inRange(img, lower_green11, upper_green11)
    
    lower_green12 = np.array([85, 85, 175])
    upper_green12 = np.array([90, 95, 185])
    green_mask12 = cv2.inRange(img, lower_green12, upper_green12)
    
    lower_green13 = np.array([75, 60, 175])
    upper_green13 = np.array([85, 80, 195])
    green_mask13 = cv2.inRange(img, lower_green13, upper_green13)
    
    lower_green14 = np.array([80, 105, 120])
    upper_green14 = np.array([90, 125, 130])
    green_mask14 = cv2.inRange(img, lower_green14, upper_green14)
    
    lower_green15 = np.array([25, 10, 140])
    upper_green15 = np.array([40, 80, 240])
    green_mask15 = cv2.inRange(img, lower_green15, upper_green15)
    
    lower_green16 = np.array([40, 35, 230])
    upper_green16 = np.array([45, 50, 250])
    green_mask16 = cv2.inRange(img, lower_green16, upper_green16)
    
    lower_green17 = np.array([50, 85, 65])
    upper_green17 = np.array([90, 230, 165])
    green_mask17 = cv2.inRange(img, lower_green17, upper_green17)
    
    lower_green18 = np.array([35, 85, 75])
    upper_green18 = np.array([50, 255, 220])
    green_mask18 = cv2.inRange(img, lower_green18, upper_green18)
    
    lower_green19 = np.array([35, 55, 160])
    upper_green19 = np.array([50, 175, 255])
    green_mask19 = cv2.inRange(img, lower_green19, upper_green19)
    
    lower_green20 = np.array([35, 175, 200])
    upper_green20 = np.array([40, 205, 240])
    green_mask20 = cv2.inRange(img, lower_green20, upper_green20)
    
    lower_green21 = np.array([50, 60, 155])
    upper_green21 = np.array([60, 120, 220])
    green_mask21 = cv2.inRange(img, lower_green21, upper_green21)
    
    lower_green22 = np.array([35, 185, 135])
    upper_green22 = np.array([45, 255, 255])
    green_mask22 = cv2.inRange(img, lower_green22, upper_green22)
    
    lower_green23 = np.array([60, 110, 35])
    upper_green23 = np.array([70, 150, 50])
    green_mask23 = cv2.inRange(img, lower_green23, upper_green23)
    
    lower_green24 = np.array([55, 165, 30])
    upper_green24 = np.array([65, 230, 45])
    green_mask24 = cv2.inRange(img, lower_green24, upper_green24)
    
    lower_green25 = np.array([60, 90, 35])
    upper_green25 = np.array([70, 210, 95])
    green_mask25 = cv2.inRange(img, lower_green25, upper_green25)
    
    lower_green26 = np.array([50, 55, 85])
    upper_green26 = np.array([60, 105, 135])
    green_mask26 = cv2.inRange(img, lower_green26, upper_green26)
    
    lower_green27 = np.array([45, 105, 35])
    upper_green27 = np.array([50, 190, 65])
    green_mask27 = cv2.inRange(img, lower_green27, upper_green27)
    
    lower_green28 = np.array([50, 105, 20])
    upper_green28 = np.array([65, 225, 70])
    green_mask28 = cv2.inRange(img, lower_green28, upper_green28)
    
    lower_green29 = np.array([40, 70, 100])
    upper_green29 = np.array([50, 120, 160])
    green_mask29 = cv2.inRange(img, lower_green29, upper_green29)
    
    lower_green30 = np.array([35, 10, 100])
    upper_green30 = np.array([55, 100, 205])
    green_mask30 = cv2.inRange(img, lower_green30, upper_green30)
    
    lower_green31 = np.array([45, 70, 48])
    upper_green31 = np.array([55, 155, 110])
    green_mask31 = cv2.inRange(img, lower_green31, upper_green31)
    
    lower_green32 = np.array([65, 45, 175])
    upper_green32 = np.array([80, 90, 200])
    green_mask32 = cv2.inRange(img, lower_green32, upper_green32)
    
    lower_green33 = np.array([45, 190, 45])
    upper_green33 = np.array([50, 235, 70])
    green_mask33 = cv2.inRange(img, lower_green33, upper_green33)
    
    lower_green34 = np.array([55, 45, 50])
    upper_green34 = np.array([75, 85, 95])
    green_mask34 = cv2.inRange(img, lower_green34, upper_green34)
    
    lower_green35 = np.array([45, 165, 65])
    upper_green35 = np.array([50, 185, 75])
    green_mask35 = cv2.inRange(img, lower_green35, upper_green35)
    
    ### Blue
    lower_blue = np.array([105, 30, 240])
    upper_blue = np.array([110, 75, 255])
    blue_mask = cv2.inRange(img, lower_blue, upper_blue)
    
    lower_blue1 = np.array([0, 0, 250])
    upper_blue1 = np.array([150, 5, 255])
    blue_mask1 = cv2.inRange(img, lower_blue1, upper_blue1)
    
    lower_blue2 = np.array([85, 35, 250])
    upper_blue2 = np.array([95, 40, 255])
    blue_mask2 = cv2.inRange(img, lower_blue2, upper_blue2)
    
    lower_blue3 = np.array([105, 70, 240])
    upper_blue3 = np.array([110, 90, 255])
    blue_mask3 = cv2.inRange(img, lower_blue3, upper_blue3)
    
    lower_blue4 = np.array([90, 40, 250])
    upper_blue4 = np.array([100, 55, 255])
    blue_mask4 = cv2.inRange(img, lower_blue4, upper_blue4)
    
    lower_blue5 = np.array([80, 0, 0])
    upper_blue5 = np.array([110, 10, 255])
    blue_mask5 = cv2.inRange(img, lower_blue5, upper_blue5)
    
    lower_blue6 = np.array([80, 15, 225])
    upper_blue6 = np.array([95, 35, 255])
    blue_mask6 = cv2.inRange(img, lower_blue6, upper_blue6)
    
    
    
    # Merge the green and blue masks
    green_mask = cv2.bitwise_or(green_mask, green_mask1)
    green_mask = cv2.bitwise_or(green_mask, green_mask2)
    green_mask = cv2.bitwise_or(green_mask, green_mask3)
    green_mask = cv2.bitwise_or(green_mask, green_mask4)
    green_mask = cv2.bitwise_or(green_mask, green_mask5)
    green_mask = cv2.bitwise_or(green_mask, green_mask6)
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
    green_mask = cv2.bitwise_or(green_mask, green_mask26)
    green_mask = cv2.bitwise_or(green_mask, green_mask27)
    green_mask = cv2.bitwise_or(green_mask, green_mask28)
    green_mask = cv2.bitwise_or(green_mask, green_mask29)
    green_mask = cv2.bitwise_or(green_mask, green_mask30)
    green_mask = cv2.bitwise_or(green_mask, green_mask31)
    green_mask = cv2.bitwise_or(green_mask, green_mask32)
    green_mask = cv2.bitwise_or(green_mask, green_mask33)
    green_mask = cv2.bitwise_or(green_mask, green_mask34)
    green_mask = cv2.bitwise_or(green_mask, green_mask35)
    green_mask = cv2.bitwise_or(green_mask, blue_mask)
    green_mask = cv2.bitwise_or(green_mask, blue_mask1)
    green_mask = cv2.bitwise_or(green_mask, blue_mask2)
    green_mask = cv2.bitwise_or(green_mask, blue_mask3)
    green_mask = cv2.bitwise_or(green_mask, blue_mask4)
    green_mask = cv2.bitwise_or(green_mask, blue_mask5)
    green_mask = cv2.bitwise_or(green_mask, blue_mask6)
    

    mask = cv2.bitwise_and(brown_mask, ~green_mask)
    result = cv2.bitwise_and(img, img, mask=mask)
    result = cv2.cvtColor(result, cv2.COLOR_HSV2RGB)
    
    return result

def suppress_and_enhance(img):
    """Suppress green and enhance brown in the image.

    Args:
        img (cv2BGRimg, 360*480*3): BGR image read by cv2.imread
    """
    # 输出当前盘符
    # print(os.getcwd())
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
    # 创建掩膜
    mask = np.zeros(hsv_image.shape[:2], dtype=np.uint8)
    # start_time = time.time()
    for h_range, s_range, v_range in zip(h_brown, s_brown, v_brown):
        lower = np.array([h_range[0], s_range[0], v_range[0]])
        upper = np.array([h_range[1], s_range[1], v_range[1]])
        mask1 = cv2.inRange(hsv_image, lower, upper)
        # mask_s = cv2.inRange(hsv_image[:, :, 1], s_min, s_max)
        # mask_v = cv2.inRange(hsv_image[:, :, 2], v_min, v_max)
        # mask_class = mask_h & mask_s & mask_v
        mask = cv2.bitwise_or(mask, mask1)
    # end_time = time.time()
    # print(f"Time: {end_time-start_time}")
    # 通过掩膜提取图像
    
    ### Green
    # lower_green = np.array([40, 120, 120])
    # upper_green = np.array([50, 210, 185])
    lower_green = np.array([40, 70, 50])
    upper_green = np.array([75, 255, 255])
    # lower_green = np.array([5, 0, 20])
    # upper_green = np.array([180, 105, 180])
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
    
    # lower_green6 = np.array([20, 65, 115])
    # upper_green6 = np.array([35, 120, 190])
    # green_mask6 = cv2.inRange(hsv_image, lower_green6, upper_green6)
    
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
    # green_mask = cv2.bitwise_or(green_mask, green_mask6)
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
    
    ### 应该是无条件保留棕色的情况下，去除绿色
    mask = cv2.bitwise_and(mask, ~green_mask)
    extracted_image = cv2.bitwise_and(img, img, mask=mask)
    # bgr to rgb
    extracted_image = cv2.cvtColor(extracted_image, cv2.COLOR_BGR2RGB)
    return extracted_image

def rgb_tagging(enhanced_img):
    """tag the rgb image

    Args:
        enhanced_img (cv2RGBimg, 360*480*3): enhanced RGB image
    """
    ### RGB质量判断
    # 计算RGB图像上3/4，中间1/3处的像素点比例
    # 定义要统计的区域
    roi = enhanced_img[0:int(3/4*SHAPE[0]), int(SHAPE[1]/3):int(2*SHAPE[1]/3)]
    # 转为灰度
    roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
    # 总像素数
    area_total = roi.shape[0] * roi.shape[1]
    # 统计有效像素
    area_valid = np.count_nonzero(roi)
    # 计算比例 
    rgb_percent = area_valid / area_total
    # 记录percent
    # percent_list.append(percent)
    # if rgb_percent <0.2:
    #     print("RGB image",index,"is not good")
    return rgb_percent

def depth_tagging(enhandced_img, depth_img):
    ### Depth质量判断
    rgb_roi = enhandced_img.copy()
    rgb_roi[:, 0:int(SHAPE[1]/3)] = 0
    rgb_roi[:, int(SHAPE[1]*2/3):] = 0
    # 转为二值图像
    _, rgb_roi = cv2.threshold(rgb_roi, 0, 255, cv2.THRESH_BINARY)
    rgb_roi = rgb_roi[:, :, 0]
    # 膨胀5个像素
    rgb_roi = cv2.dilate(rgb_roi, np.ones((5, 5), np.uint8), iterations=1)
    # 提取depth_img中rgb_roi区域的深度值
    depth_values = depth_img[rgb_roi > 0]
    # 桶化
    bins = np.arange(np.min(depth_values), np.max(depth_values), 0.03)
    digitized_center_depths = np.digitize(depth_values, bins)
    mode_depth = bins[stats.mode(digitized_center_depths, axis=None).mode][0]

    # zero out depth values that are not within 10% of the mode center depth
    depth_approx = 0.1 * mode_depth
    depth_filtered = depth_img.copy()
    # For those pixels that are not within 10% of the mode center depth, set them to 0
    depth_filtered[np.abs(depth_filtered - mode_depth) > depth_approx] = 0
    # plt.imshow(depth_filtered, cmap='gray')
    middle_area_valid = np.count_nonzero(depth_filtered[:,int(SHAPE[1]/3):int(2*SHAPE[1]/3)])
    side_area_valid = np.count_nonzero(depth_filtered[:,0:int(SHAPE[1]/3)]) + np.count_nonzero(depth_filtered[:,int(2*SHAPE[1]/3):])
    if side_area_valid != 0:
        middle_side_ratio = middle_area_valid / side_area_valid
        # if middle_side_ratio < 1:
        #     print(index,"middle_side_ratio:",middle_side_ratio)
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
    """计算直线的斜率和截距"""
    """line:(x1, y1, x2, y2)"""
    # x1, y1, x2, y2 = line
    # slope = (y2 - y1) / (x2 - x1)
    # intercept = y1 - slope * x1
    # 假设x=my+b
    x1, y1, x2, y2 = line
    slope = (x2 - x1) / (y2 - y1 + 1e-10)
    intercept = x1 - slope * y1
    return slope, intercept

def get_extend_line(slope, intercept):
    """获得延长线的两点坐标x1,y1,x2,y2"""
    # 确定直线的延长部分的两个新端点
    # 假设直线从左边界延长到右边界
    # new_x1 = 0
    # new_y1 = int(intercept)
    # new_x2 = SHAPE[0]
    # new_y2 = int(slope * new_x2 + intercept)
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
    # better denoise outside the function
    # denoise the mask
    # binary_mask = denoise(binary_mask)


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
    # 在1/3与2/3加两条竖线
    img = rgb_suppress_and_enhance.copy()
    w = img.shape[1]
    img[:,int(w//3),:] = 0
    img[:,int(2*w//3),:] = 0
    # label each pixel by connected component of image
    # The 0th label will contain background pixels (pixels with depth value 0)
    labeled = measure.label(img[:,:,0] > 0, connectivity=1, background=0)
    labels, counts = np.unique(labeled, return_counts=True)

    labeled_middle = measure.label(img[:, int(w//3):int(2*w//3),0]>0, connectivity=1, background=0)
    labels_middle, counts_middle = np.unique(labeled_middle, return_counts=True)
    # Zero out points in tiny connected components (fewer than ALPHA pixels)
    # tiny = labels_target[np.where(counts[labels_target] < ALPHA)]
    # 分段进行排除小像素点
    tiny = labels[np.where(counts[labels] < ALPHA)]
    # 判断质量，使用不同的阈值
    if rgb_quality_ratio <= 0.2:
        alpha_middle = ALPHA_MIDDLE_POOR
    else:
        alpha_middle = ALPHA
    nontiny_middle = labels_middle[np.where((counts_middle[labels_middle] > alpha_middle) & (counts_middle[labels_middle] < ALPHA))]
    A = np.isin(labeled, tiny)
    A = A.astype(int)
    B = np.isin(labeled_middle, nontiny_middle)
    B = np.pad(B, ((0, 0), (160, 160)), 'constant', constant_values=False)
    B = B.astype(int)
    tiny_final = cv2.bitwise_xor(A, B)
    tiny_final = tiny_final.astype(bool)

    img[tiny_final] = 0.0
    # 转回RGB
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    # Open to denoise
    kernel = np.ones((2,2),np.uint8)
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
    ######################### 修改 #########################
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
    #### Amelia's method
    # sorted_labels = labels[sorted_inds[::-1]]
    # inlier_area = np.sum(counts)
    # for i in range(len(sorted_labels) - 1):  # Must keep at least one component
    #     # Check that the convex hull of the components is sufficiently dense in trunk inliers
    #     # by examining the ratio of the pixel area in remaining components
    #     # to the total area of the convex hull
    #     # ConvexHull computed using http://www.qhull.org/
    #     hull = spatial.ConvexHull(np.argwhere(img > 0))
    #     hull_density = inlier_area / hull.volume
    #     if hull_density > BETA:
    #         break
    #     else:
    #         # If not, remove the component whose x-mean is furhest from the target component
    #         remove = sorted_labels[i]
    #         img[labeled == remove] = 0.0
    #         labeled[labeled == remove] = 0
    #         inlier_area = inlier_area - counts[remove - 1]
    #         print(1)
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
    # 计算平均y坐标（高度）
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
    # 生成白色背景
    mask = np.zeros_like(img[:,:,0])
    if hull.volume < 10000:
        # print(f"{img_index}:","Bad RGB image")
        # 生成一个中间1/3的mask
        mask[:, int(w//3):int(2*w//3)] = 255
    else:
#         if hull.volume < 50000:
#             #TODO: 完善这个部分，一个想法是把rgb_quality_ratio作为全局变量，然后在这里使用
#             print("Poor RGB image")
        # 填充多边形内部
        cv2.fillPoly(mask, [points], 255)
    return hull_img, mask

def filter_depth_img_with_centralpixel(depth, rgb_hull_img):
    """Filter the depth image to retain the trunk part"""
    depth_img = depth.copy()
    depth_img[depth_img > 5] = 0
    # 读取RGB图像
    rgb_img = rgb_hull_img.copy()
    middle = 240
    middle_ten = np.arange(middle-2, middle+2)
    middle_ten = middle_ten.tolist()
    # 取出中列像素值
    mid_vals = [depth_img[180, int(c)] for c in middle_ten]
    # 计算均值
    mode_depth = np.mean(mid_vals)
    # zero out depth values that are not within 10% of the mode center depth
    depth_approx = 0.2 * mode_depth
    depth_filtered = depth_img.copy()
    # depth_filtered[mask_img[:,:,0] == 0] = 0
    depth_filtered[rgb_img[:,:,0] == 0] = 0
    # For those pixels that are not within 10% of the mode center depth, set them to 10m(very far away)
    depth_filtered[np.abs(depth_filtered - mode_depth) > depth_approx] = 10
    # 标准化到0-255
    depth_filtered = (depth_filtered - depth_filtered.min()) / (depth_filtered.max() - depth_filtered.min()) * 255
    return depth_filtered

def edge_detection(prediction):
    # 获取高度和宽度
    h,w = prediction.shape[:2]
    # 进行Canny边缘检测
    pre_img = prediction.copy()
    pre_img = pre_img.astype(np.uint8)
    edges = cv2.Canny(pre_img, threshold1=50, threshold2=150)
    return edges

def find_best_parallel_line(edges, rgb_quality_ratio):
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, threshold=30, minLineLength=30, maxLineGap=50)
    # 如果lines为空，则跳过此次循环：
    if lines is None:
        raise ParallelLineNotFoundError
    # 初始化最小距离之和和对应的平行线端点
    best_parallel_lines = []
    # 首先排除所有的过于倾斜的线段（水平夹角小于30度）
    for line in lines:
        x1, y1, x2, y2 = line[0]
        angle = np.abs(np.arctan2(y2 - y1, x2 - x1))
        # print(f"angle: {angle}")
        if np.abs(angle) < np.pi / 5:
            rows = np.where((lines == line).all(axis=2))[0]
            # 根据索引删除
            lines = np.delete(lines, rows, axis=0)
    # 定义最短距离的threshold
    if rgb_quality_ratio <= 0.2:
        min_dist = 10
    else:
        min_dist = 20
    for line1 in lines:
        x1, y1, x2, y2 = line1[0]
        for line2 in lines:
            x3, y3, x4, y4 = line2[0]
            if np.array_equal(line1[0], line2[0]) == False:
                # 计算两条线段的角度差在一定范围内认为它们是平行的
                angle_diff = np.abs(np.arctan2(y2 - y1, x2 - x1) - np.arctan2(y4 - y3, x4 - x3))
                if np.abs(angle_diff) < np.pi/16 or np.abs(angle_diff-np.pi) < np.pi/16:
                    # 排除两条线相交的情况
                    k1, b1 = calculate_kandb(line1[0])
                    k2, b2 = calculate_kandb(line2[0])
                    y0 = (b2 - b1) / (k1 - k2 + 1e-10)
                    x0 = k1 * y0 + b1
                    if 0 <= x0 < SHAPE[1] and 0 <= y0 < SHAPE[0]:
                        continue
                    # 计算两条线段在图像顶部与底部的长度和，若小于某个值，也排除
                    new_x1, new_y1 ,new_x2, new_y2 = get_extend_line(k1, b1)
                    new_x3, new_y3 ,new_x4, new_y4 = get_extend_line(k2, b2)
                    # 结合RGB的标签进行阈值确定（细小的树木可以把它的阈值设小一些）
                    if np.abs(new_x1 - new_x3) < min_dist or np.abs(new_x2 - new_x4) < min_dist:
                        continue
                    # 满足条件后，写入best_parallel_lines
                    best_parallel_lines.append([(x1, y1, x2, y2), (x3, y3, x4, y4)])
    # 删除重复的平行线组合
    best_parallel_lines = set(tuple(sorted(item)) for item in best_parallel_lines)
    # 将集合转换回列表
    best_parallel_lines = [tuple(item) for item in best_parallel_lines]
    if not best_parallel_lines:
        raise ParallelLineNotFoundError
    sum_distance_list = []
    for line_dist in best_parallel_lines:
        # distx = np.abs(line_dist[0][0] - line_dist[0][2]) + np.abs(line_dist[0][1] - line_dist[0][3])
        disty = np.abs(line_dist[0][1] - line_dist[0][3]) + np.abs(line_dist[1][1] - line_dist[1][3])
        # sum_distance = distx + disty
        sum_distance = disty
        sum_distance_list.append(sum_distance)
    # 选择距离最大的两条线
    line_draw = best_parallel_lines[sum_distance_list.index(max(sum_distance_list))]
    return line_draw

def get_two_cross_distance(k1, k2, b1, b2, y0):
    # 求垂线与两边界线的交点距离
    # y0为垂线的y坐标
    y1 = (k1+k2)/(k1*(k1+k2)+2)*(((k1+k2)/2+2/(k1+k2+1e-8))*y0+(b2-b1)/2)
    x1 = k1*y1+b1
    y2 = (k1+k2)/(k2*(k1+k2)+2)*(((k1+k2)/2+2/(k1+k2+1e-8))*y0+(b1-b2)/2)
    x2 = k2*y2+b2
    dist = np.sqrt((x1-x2)**2+(y1-y2)**2)
    return dist

def fit_line(best_lines,edges):
    h,w = 360,480
    # TODO:尝试两组线？最终还是只是画一条，但是两组线可以增大选中的像素
    line_draw = best_lines
    slope1, intercept1 = calculate_kandb(line_draw[0])
    slope2, intercept2 = calculate_kandb(line_draw[1])
    # 获取延长线的绘制点
    new_x1, new_y1 ,new_x2, new_y2 = get_extend_line(slope1, intercept1)
    new_x3, new_y3 ,new_x4, new_y4 = get_extend_line(slope2, intercept2)
    # 绘制从新端点到图像边界的直线
    # 创建一个360, 480, 3的全0数组
    canvans = np.zeros((h, w, 3), dtype=np.uint8)
    cv2.line(canvans, (new_x1, new_y1), (new_x2, new_y2), (255, 255, 255), 2)
    cv2.line(canvans, (new_x3, new_y3), (new_x4, new_y4), (255, 255, 255), 2)
    # # 画出所有的lines
    # 对于canvans进行膨胀操作
    kernel = np.ones((10, 10), np.uint8)
    canvans = cv2.dilate(canvans, kernel, iterations=1)
    # 求canvans每行的平均列值
    row_means = np.zeros(h)
    for i in range(h):
        cols = np.where(canvans[i] > 0)[0]
        row_means[i] = cols.mean()
    # 对于row_means取整
    row_means = row_means.astype(int)
    for line in line_draw:
        x1, y1, x2, y2 = line
        cv2.line(canvans, (x1, y1), (x2, y2), (255, 255, 255), 2)
        # print(f"line: {line}")
    # 提取canvas中的edge
    # 将edge变为三通道
    edges_copy = edges.copy()
    edges_copy = cv2.cvtColor(edges_copy, cv2.COLOR_GRAY2BGR)
    canvans = cv2.bitwise_and(canvans, edges_copy)

    left = np.zeros_like(canvans)
    right = np.zeros_like(canvans)

    for i in range(canvans.shape[0]):
        scanner = np.where(canvans[i,:]!=0)
        # 若scanner不为空
        if scanner[0].size != 0:
            left_idx = scanner[0][0]
            right_idx = scanner[0][-1]
            if left_idx < row_means[i]:
                left[i, left_idx] = canvans[i, left_idx]
            if right_idx > row_means[i]:
                right[i, right_idx] = canvans[i, right_idx]
    #先画左边
    coords = np.argwhere(left)
    # 交换两列顺序
    coords[:, [0, 1]] = coords[:, [1, 0]]
    pixel_coords = [tuple(coord) for coord in coords]
    # 对于线条进行拟合，得到线条的方程
    # 将points中每个tuple的x和y分别取出，分别存入x和y中
    x = []
    y = []
    for i in range(len(pixel_coords)):
        x.append(pixel_coords[i][0])
        y.append(pixel_coords[i][1])
    # 用numpy的polyfit函数进行拟合，得到线条的方程
    z1 = np.polyfit(y, x, 1)
    # 用numpy的poly1d函数生成方程
    p1 = np.poly1d(z1)
    # 生成y轴上的点
    y_axis = np.linspace(0, 359, 360)
    # 生成x轴上的点
    x_axis = p1(y_axis)
    # 将x_axis, y_axis中的浮点数转换为整数
    x_axis = x_axis.astype(int)
    y_axis = y_axis.astype(int)
    # 将x_axis和y_axis中的点组合成tuple，存入points2中
    points1 = []
    for i in range(len(x_axis)):
        points1.append((x_axis[i], y_axis[i]))
    #再画右边
    coords = np.argwhere(right)
    # 交换两列顺序
    coords[:, [0, 1]] = coords[:, [1, 0]]
    pixel_coords = [tuple(coord) for coord in coords]
    # 对于线条进行拟合，得到线条的方程
    # 将points中每个tuple的x和y分别取出，分别存入x和y中
    x = []
    y = []
    for i in range(len(pixel_coords)):
        x.append(pixel_coords[i][0])
        y.append(pixel_coords[i][1])
    # 用numpy的polyfit函数进行拟合，得到线条的方程
    z1 = np.polyfit(y, x, 1)
    # 用numpy的poly1d函数生成方程
    p1 = np.poly1d(z1)
    # 生成y轴上的点
    y_axis = np.linspace(0, 359, 360)
    # 生成x轴上的点
    x_axis = p1(y_axis)
    # 将x_axis, y_axis中的浮点数转换为整数
    x_axis = x_axis.astype(int)
    y_axis = y_axis.astype(int)
    # 将x_axis和y_axis中的点组合成tuple，存入points2中
    points2 = []
    for i in range(len(x_axis)):
        points2.append((x_axis[i], y_axis[i]))
    # 将points2中的点绘制成线条
    # 将两条线合并画出
    canvans = np.zeros_like(left, dtype=np.uint8)
    for i in range(len(points2) - 1):
        if (points1[i][1] < 360) & (points1[i][0] < 480):
            canvans[points1[i][1], points1[i][0]] = 255
        if (points2[i][1] < 360) & (points2[i][0] < 480):
            canvans[points2[i][1], points2[i][0]] = 255
    # 膨胀两个像素，使得线条更加粗
    kernel = np.ones((2, 2), np.uint8)
    canvans = cv2.dilate(canvans, kernel, iterations=1)
    return canvans

def calculate_DBH(depth,best_lines):
    ### 计算DBH ###
    new_height = 360
    depth_txt = depth.copy()
    # 计算两条直线于图像中央的X坐标
    slope1, intercept1 = calculate_kandb(best_lines[0])
    slope2, intercept2 = calculate_kandb(best_lines[1])
    left = slope1 * (new_height // 2) + intercept1
    right = slope2 * (new_height // 2) + intercept2
    # 计算平均像素长
    dm = get_two_cross_distance(slope1, slope2, intercept1, intercept2, new_height // 2)
    dm_up = get_two_cross_distance(slope1, slope2, intercept1, intercept2, new_height // 6)
    dm_down = get_two_cross_distance(slope1, slope2, intercept1, intercept2, new_height // 6 * 5)
    dm_average = (dm_up + dm_down + dm) / 3
    # 选择left与right作为边界构成的列表中最中间的5个值
    # 计算中间数
    middle = (left + right) // 2
    # 生成序列
    middle_ten = np.arange(middle-2, middle+2)
    middle_ten = middle_ten.tolist()
    # 取出中列像素值
    mid_vals = [depth_txt[new_height//2, int(c)] for c in middle_ten]
    # 计算均值
    mode_depth = np.mean(mid_vals)
    # 计算直径
    GAMMA = 356.25
    D = mode_depth/(GAMMA/dm_average-np.sqrt(0.25-25/dm_average**2))
    return D

def find_one_point_three_meter(depth, device_height):
    ### 利用depth寻找1.3m位置
    GAMMA = 356.25
    delta_h_depth = depth.copy()
    # 除以GAMMA获取深度图中每个像素代表的高度
    delta_h_depth = delta_h_depth / GAMMA
    central_pixel_height = device_height
    # 初始化搜索的起始点
    move_point = [180, 240]
    # 判断central_pixel_height与1.3m关系
    # 如果central_pixel_height < 1.3m,则向图像上方搜索
    if central_pixel_height < 1.3:
        move_direction = 1
    else:
        move_direction = -1
    move_range = [-1,0,1]
    height = central_pixel_height
    while np.abs(height-1.3) > 0.01:
        # 寻找central_pixel上面三个像素点的实际高度，找到与move_point深度最接近的点
        delta_depth_list = []
        for i in move_range:
            delta_depth = np.abs(depth[move_point[0] - i, move_point[1]] - depth[move_point[0], move_point[1]])
            delta_depth_list.append(delta_depth)
        # 找出最小的delta_depth_list中最小的索引
        min_index = delta_depth_list.index(min(delta_depth_list))
        # 更新move_point
        move_point[0] = move_point[0] - move_direction
        move_point[1] = move_point[1] + move_range[min_index]
        # 更新height
        height = height + delta_h_depth[move_point[0], move_point[1]] * move_direction
        # 将move_point处的delta_h_depth设为0.2
        delta_h_depth[move_point[0], move_point[1]] = 0.1
    # 交换move_point的x和y坐标
    move_point[0], move_point[1] = move_point[1], move_point[0]
    return move_point

def calculate_ratio_inside_box(extract_img):
    # 计算30*30的小方块内有像素点的个数
    count = 0
    rgb_width = 480
    rgb_height = 360
    for i in range(rgb_width//2-15, rgb_width//2+15):
        for j in range(rgb_height//2-15, rgb_height//2+15):
            if extract_img[j][i][0] != 0:
                count += 1
    # 计算方框内的像素点的比例
    return count/(30*30)

def fuse_line_with_bgr(canvans_with_lines,bgr):
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    fuse_img = cv2.addWeighted(canvans_with_lines, 1, rgb, 1, 0)
    return fuse_img
    





