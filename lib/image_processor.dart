import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:chaquopy/chaquopy.dart';
import 'package:flutter/material.dart';
import 'package:tree/utils/image_util.dart';

import 'image_processor_interface.dart';

class ImageProcessor implements ImageProcessorInterface {
  static const List<int> SHAPE = [480, 640];

  @override
  Future<ImageResult> processImage(BuildContext context, ImageRaw raw) async {
    String rgbMatBase64 = base64Encode(raw.rgbMat ?? Uint8List(0));
    String dBufferStr = raw.arMat?.dBuffer.join(",") ?? "";

    final code = '''
import sys
import os
import base64
import numpy as np
import improc

sys.stderr = open(os.devnull, 'w')

rgb_arr = base64.b64decode("$rgbMatBase64")

dBuffer = np.fromstring("$dBufferStr", sep=',')

result = improc.run(dBuffer, rgb_arr, ${raw.rgbWidth}, ${raw.rgbHeight}, ${raw.arWidth}, ${raw.arHeight})

print(result)

''';

    // Show a loading indicator
    final loadingDialog = _showLoadingDialog(context);

    // Run the Python code and wait for the result
    try {
      final result = await Chaquopy.executeCode(code).timeout(Duration(minutes: 5));
      print(result);
      print(result['textOutputOrError']);

      Map<String, dynamic> resultJson = jsonDecode(result['textOutputOrError']);

      final rgbDispNorm = resultJson['rgb_disp_norm'];
      double estDepth = resultJson['est_depth'];
      double estWidth = resultJson['est_width'];
      String logInfo = resultJson['log_info'];

      Uint8List rgbDisp = base64Decode(rgbDispNorm);

      ImageResult imageResult = ImageResult();

      ui.Image image = await ImageUtil.decodeImageFromList(
          rgbDisp, SHAPE[1], SHAPE[0]);

      imageResult.displayImage = image;
      imageResult.rgbImage = raw.rgbMat;
      imageResult.depthImage = raw.arMat;
      imageResult.depth = estDepth;
      imageResult.diameter = estWidth;
      imageResult.logInfo = logInfo;

      /*print(estDepth);
    print(estWidth);
    print(logInfo);*/


      return imageResult;
    } catch (e) {
      print("Error processing image: $e");
      rethrow;
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