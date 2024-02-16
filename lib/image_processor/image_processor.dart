import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chaquopy/chaquopy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GreenLens/utils/exceptions.dart';

import 'image_processor_interface.dart';

class ImageProcessor implements ImageProcessorInterface {
  static const List<int> SHAPE = [480, 640];

  _showLoadingDialog(BuildContext? context) {
    return showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Processing image..."),
            ],
          ),
        );
      },
    );
  }

  @override
  Future<Map<String, dynamic>> processImage(
      BuildContext context, ImageRaw raw) async {
    _showLoadingDialog(context);
    try {
      const MethodChannel _channel = MethodChannel('com.example.tree/torch_model');

      final Map<String, dynamic> params = {
        'rgbMat': raw.rgbMat,
        'depthArr': raw.arMat!.dBuffer,
        'depthWidth': raw.arWidth,
        'depthHeight': raw.arHeight,
      };

      final result = await _channel.invokeMethod('process_image', params);

      Map<String, dynamic> resultMap = jsonDecode(result);

      String imgBase64 = resultMap['img'];
      double preDBH = resultMap['pre_DBH'];
      String line = resultMap['line_json'];

      Uint8List resultImg = base64Decode(imgBase64);

      ImageResult imageResult = ImageResult();

      Image image = Image.memory(resultImg);

      imageResult.displayImage = image;
      imageResult.rgbImage = raw.rgbMat;
      imageResult.depthImage = raw.arMat;
      imageResult.diameter = preDBH;
      imageResult.lineJson = line;

      return {
        'imageResult': imageResult,
        'diameter': preDBH,
        'lineJson': line,
      };
    } on PlatformException catch (e) {
      switch (e.code) {
        case "NoTrunkFoundError":
          throw NeedManualInputException(e.code, e.message!);
        case "ParallelLineNotFoundError":
          throw NeedManualInputException(e.code, e.message!);
        default:
          throw ImageProcessException(e.message!);
      }
    } catch (e) {
      throw ImageProcessException(e.toString());
    } finally {
      // Hide the loading indicator
      Navigator.pop(context);
    }
  }
}
