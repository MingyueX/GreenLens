import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chaquopy/chaquopy.dart';

import 'image_processor_interface.dart';

/// not used in final product, testing depth evaluation only
class DepthEvaluator {
  Future<String> evaluateDepth(ImageRaw raw) async{
    String rgbMatBase64 = base64Encode(raw.rgbMat ?? Uint8List(0));
    String dBufferStr = raw.arMat?.dBuffer.join(",") ?? "";

    final code = '''
import sys
import os
import base64
import numpy as np
import improc_depth_evaluator

sys.stderr = open(os.devnull, 'w')

rgb_arr = base64.b64decode("$rgbMatBase64")

dBuffer = np.fromstring("$dBufferStr", sep=',', dtype=np.float64)

result = improc_depth_evaluator.run(dBuffer, rgb_arr, ${raw.rgbWidth}, ${raw.rgbHeight}, ${raw.arWidth}, ${raw.arHeight})

print(result)

''';
    final result = await Chaquopy.executeCode(code);
    print(result);
    print(result['textOutputOrError']);

    return result['textOutputOrError'];
  }
}