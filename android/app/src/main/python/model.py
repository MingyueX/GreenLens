import numpy as np
import torch
import matplotlib.pyplot as plt
import pytorch_lightning as pl
import segmentation_models_pytorch as smp
import torch.nn.functional as F
import os

from typing import Any, Dict, cast
from torchvision import transforms
from skimage.transform import resize


class SegModel(pl.LightningModule):
    def config_task(self) -> None:
        encoder_weights = self.hyperparams.get("encoder_weights", None)
        if encoder_weights == "local":
            encoder_weights = None
        self.net = smp.Unet(
            encoder_name=self.hyperparams["encoder_name"],
            encoder_weights=encoder_weights,
            in_channels=self.hyperparams["in_channels"],
            classes=self.hyperparams["num_classes"],
        )

    def __init__(self, **kwargs: Any,) -> None:
        super().__init__()

        # Creates `self.hparams` from kwargs
        self.save_hyperparameters()  # type: ignore[operator]
        self.hyperparams = cast(Dict[str, Any], self.hparams)

        self.ignore_zeros = None if kwargs["ignore_zeros"] else 0
        self.config_task()

    def forward(self, x):
        # print("input shape: ", x.shape)
        return self.net(x)


# set random seed for reproducibility
pl.seed_everything(21)

# Global variable to store the model
model = None

def load_model():
    global model
    if model is None:
        model = SegModel(
            in_channels=1,
            encoder_name="resnet34",
            # encoder_weights="imagenet",
            encoder_weights="local",
            num_classes=1,
            ignore_zeros=0,
        )

        # Load the weights
        weights_path = os.path.join(os.path.dirname(__file__),'weights', 'resnet34-333f7ec4.pth')
        state_dict = torch.load(weights_path, map_location='cpu')
        conv1_weight = state_dict['conv1.weight']
        conv1_weight_new = conv1_weight.mean(dim=1, keepdim=True)
        state_dict['conv1.weight'] = conv1_weight_new

        model.net.encoder.load_state_dict(state_dict)

        current_dir = os.path.dirname(__file__)
        ckpt_path = os.path.join(current_dir, "april_1_40.ckpt")
        model = model.load_from_checkpoint(ckpt_path)

def run(depth): #depth is a np array (360, 480)
    global model
    if model is None:
        load_model()

    ## img = depth.resize(120, 160)
    img = np.resize(depth, (120, 160))
    transform = transforms.Compose([transforms.ToTensor(), transforms.Normalize([3.2749], [1.6713])])
    img = transform(img).float()
    img = F.pad(img, (0, 0, 4, 4), "constant", 0)
    img = img.numpy()
    img = np.expand_dims(img, axis=0)
    # converting back to torch.tensor
    img = torch.from_numpy(img)
    # print("data_path:", file_path, ":size: ", img.shape)
    logits = model(img)
    preds = torch.squeeze((logits.sigmoid() > 0.5).int(), dim=1)
    # plt.imshow(preds[0, :, :])
    # plt.show()
    return preds # returns (128, 160)
