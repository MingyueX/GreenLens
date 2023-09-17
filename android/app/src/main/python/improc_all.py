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
from models.BBSNet_model import BBSNet

global model, transform, depths_transform

def initialize_model():
    global model, transform, depths_transform

    # Load the model
    model = BBSNet()
    #Large epoch size may not generalize well. You can choose a good model to load according to the log file and pth files saved in ('./BBSNet_cpts/') when training.
    weights_path = os.path.join(os.path.dirname(__file__),'models', 'BBSNet_epoch_best.pth')
    model.load_state_dict(torch.load(weights_path, map_location='cpu'))
#     model.cuda()
    model.eval()

    transform = transforms.Compose([
        transforms.Resize((352, 352)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    depths_transform = transforms.Compose([transforms.Resize((352, 352)),transforms.ToTensor()])

def run(depth_arr, rgb_arr, rgb_width, rgb_height, depth_width, depth_height):
    global model, transform, depths_transform

    # #####  DIY  #####
    # test_num = 3
    # depth_height, depth_width = 120, 160
    # depth_path = f"E:/Codes/PythonFiles/Projects/tree-segmentation-main-7.10/data/all/Frank's/depthtxt/depthImgData_{test_num}"
    # with open(f"E:/Codes/PythonFiles/Projects/tree-segmentation-main-7.10/data/all/Frank's/rgb_jpg/{test_num}.jpg", 'rb') as image_file:
    #     rgb_arr = image_file.read()
    # depth_arr = np.loadtxt(depth_path, delimiter=",", usecols=range(0, 3))
    # ##################

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
    bgr = cv2.imdecode(np.frombuffer(io_buf.getbuffer(), dtype=np.uint8), -1)
    # resize the image to 360x480
    bgr = cv2.resize(bgr, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    # suppress green and extract brown
    extract_img = suppress_and_enhance(bgr)
    # get rgb and depth quality ratio
    rgb_quality_ratio = rgb_tagging(extract_img)
    depth_quality_ratio = depth_tagging(extract_img,depth)
    # denoise rgb
    denoised_rgb = denoise_rgb_suppress_and_enhance(extract_img, rgb_quality_ratio)
    # get hull image and mask
    hull_img, hull_mask = get_hull_img_and_mask(denoised_rgb)
    # filter depth image using modal depth within the hull image
    filter_depth_img = filter_depth_img_with_centralpixel(depth, hull_img)

    ########## Inference ##########
#     transform = transforms.Compose([
#         transforms.Resize((352, 352)),
#         transforms.ToTensor(),
#         transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
#     ])
#     depths_transform = transforms.Compose([transforms.Resize((352, 352)),transforms.ToTensor()])

    image_rgb = Image.fromarray(cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB))
    image_rgb = transform(image_rgb).unsqueeze(0)

    img_depth = Image.fromarray(filter_depth_img)
    img_depth = img_depth.convert('L')
    gt = img_depth.copy()
    img_depth = depths_transform(img_depth).unsqueeze(0)
    gt = np.asarray(gt, np.float32)
    gt /= (gt.max() + 1e-8)
#     image_rgb = image_rgb.cuda()
#     img_depth = img_depth.cuda()
    _,res = model(image_rgb,img_depth)
    res = F.upsample(res, size=gt.shape, mode='bilinear', align_corners=False)
    res = res.sigmoid().data.cpu().numpy().squeeze()
    res = (res - res.min()) / (res.max() - res.min() + 1e-8)
    res = res * 255
    ######## Inference over ########

    # get edge image
    edges = edge_detection(res)
    # find the best parallel pair
    best_lines = find_best_parallel_line(edges, rgb_quality_ratio)
    # get the trunk boundary image
    canvans_with_lines = fit_line(best_lines, edges)
    # DBH calculation
    pre_DBH = calculate_DBH(depth,best_lines)
    # print(pre_DBH)

    # fuse the lines with the bgr
    fuse_img = fuse_line_with_bgr(canvans_with_lines,bgr)

    # convert the image to base64
    img_base64 = numpy_array_to_base64(fuse_img)

#     result = {
#         "img": img_base64,
#         "pre_DBH": pre_DBH
#     }
#     result_json = json.dumps(result)
#     return result_json
    return img_base64, pre_DBH


def numpy_array_to_base64(img_array):
    # Convert numpy array to image
    _, buffer = cv2.imencode('.png', img_array)
    img_str = base64.b64encode(buffer).decode('utf-8')
    return img_str
