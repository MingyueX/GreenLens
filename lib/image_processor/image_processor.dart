import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chaquopy/chaquopy.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tree/utils/exceptions.dart';

import 'image_processor_interface.dart';

class ImageProcessor implements ImageProcessorInterface {
  static const List<int> SHAPE = [480, 640];

  @override
  Future<Map<String, dynamic>> processImage(BuildContext context, ImageRaw raw) async {
    String rgbMatBase64 = base64Encode(raw.rgbMat ?? Uint8List(0));
    String dBufferStr = raw.arMat!.dBuffer.join("\n");
    String dBufferBase64 = base64Encode(utf8.encode(dBufferStr));
    final code = '''
import sys
import os
import base64
import numpy as np
import improc_all
import traceback

def main(rgb_base64, dBuffer_base64):

    rgb_arr = base64.b64decode(rgb_base64)

    dBufferStr_decoded = base64.b64decode(dBuffer_base64).decode('utf-8')
    depth_arr = np.array(list(map(float, dBufferStr_decoded.split('\\n'))))

    # result = improc.run(depth_arr, rgb_arr, ${raw.rgbWidth}, ${raw.rgbHeight}, ${raw.arWidth}, ${raw.arHeight})

    return improc_all.run(depth_arr, rgb_arr, ${raw.rgbWidth}, ${raw.rgbHeight}, ${raw.arWidth}, ${raw.arHeight})

result = main("$rgbMatBase64", "$dBufferBase64")
''';

    // Show a loading indicator
    final loadingDialog = _showLoadingDialog(context);

    // Run the Python code and wait for the result
    try {
      final result =
          await Chaquopy.executeCode(code).timeout(Duration(seconds: 45));
      print(result);

      if (result['errorType'] == "NoTrunkFoundError" ||
          result['errorType'] == "ParallelLineNotFoundError") {
        throw NeedManualInputException(result['errorMessage']);
      }

      final resultJson = jsonDecode(result['returnValueJson']);

      final resultImgBase64 = resultJson[0];
      double estWidth = resultJson[1];

      Uint8List resultImg = base64Decode(resultImgBase64);

      ImageResult imageResult = ImageResult();

      Image image = Image.memory(resultImg);

      imageResult.displayImage = image;
      imageResult.rgbImage = raw.rgbMat;
      imageResult.depthImage = raw.arMat;
      imageResult.diameter = estWidth;

      return {
        'imageResult': imageResult,
        'diameter': estWidth,
      };
    } catch (e) {
      if (e is NeedManualInputException) {
        rethrow;
      } else {
        throw ImageProcessException(e.toString());
      }
    } finally {
      // Hide the loading indicator
      Navigator.pop(context);
    }
  }

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
}
