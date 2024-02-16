import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ar_flutter_plugin/models/depth_img_array.dart';
import 'package:flutter/material.dart';

abstract class ImageProcessorInterface {

  Future<Map<String, dynamic>> processImage(BuildContext context, ImageRaw raw);

}

class ImageResult {
  Image? displayImage;
  Uint8List? rgbImage;
  DepthImgArrays? depthImage;
  double diameter;
  double depth;
  String? logInfo;
  String? lineJson;

  ImageResult({
    this.displayImage,
    this.rgbImage,
    this.depthImage,
    this.diameter = 0.0,
    this.depth = 0.0,
    this.logInfo,
    this.lineJson,
  });
}

class ImageRaw {
  Uint8List? rgbMat;
  int rgbWidth;
  int rgbHeight;
  DepthImgArrays? arMat;
  int arWidth;
  int arHeight;

  ImageRaw({
    this.rgbMat,
    this.rgbWidth = 0,
    this.rgbHeight = 0,
    this.arMat,
    this.arWidth = 0,
    this.arHeight = 0,
  });
}