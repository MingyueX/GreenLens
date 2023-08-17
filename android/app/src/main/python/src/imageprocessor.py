import cv2
import numpy as np
from skimage import measure
from scipy import spatial
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats
import cv2
import os

os.chdir(os.path.dirname(__file__))

SHAPE = (360, 480)
ALPHA = 100
BETA = 0.60

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
    # Converting images from BGR color space to HSV color space
    #### 这里改为了RGB（skimage），而非RGB（cv2）
    hsv_image = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)
    
    # Defining the brown HSV range
    # Try a large range of browns for light effects
    lower_brown = np.array([0, 0, 0])
    upper_brown = np.array([40, 255, 255])

    # Creating masks based on HSV ranges
    brown_mask = cv2.inRange(hsv_image, lower_brown, upper_brown)
    result = cv2.bitwise_and(img, img, mask=brown_mask)
    result = cv2.cvtColor(result, cv2.COLOR_HSV2RGB)
    return result

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
        img (cv2RGBimg, 360*480*3): raw RGB image read by cv2.imread
    """
    # 输出当前盘符
    print(os.getcwd())
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
    
    lower_green6 = np.array([20, 65, 115])
    upper_green6 = np.array([35, 120, 190])
    green_mask6 = cv2.inRange(hsv_image, lower_green6, upper_green6)
    
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
    
    mask = cv2.bitwise_and(mask, ~green_mask)
    extracted_image = cv2.bitwise_and(img, img, mask=mask)
    
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
    if len(labels) == 0:
        # raise NoTrunkFoundError
        print("No trunk found")

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

