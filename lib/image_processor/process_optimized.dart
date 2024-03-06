import 'package:ar_flutter_plugin/models/depth_img_array.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/exceptions.dart';

class OptimizedProcessor {
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
              Text("Reprocessing image..."),
            ],
          ),
        );
      },
    );
  }

  Future<double> processImage(
      BuildContext context, DepthImgArrays? arMat, double focalLength, List<double> mns) async {
    _showLoadingDialog(context);
    try {
      const MethodChannel _channel = MethodChannel('com.example.tree/torch_model');

      final Map<String, dynamic> params = {
        'depthArr': arMat!.dBuffer,
        'm1': mns[0],
        'n1': mns[1],
        'm2': mns[2],
        'n2': mns[3],
        'gamma': focalLength
      };

      final result = await _channel.invokeMethod('process_after_adjust', params);

      double DBH = double.parse(result);

      return DBH;
    } on PlatformException catch (e) {
      switch (e.code) {
        case "NoTrunkFoundError":
          throw NeedManualInputException(e.code, e.message!);
        case "ParallelLineNotFoundError":
          throw NeedManualInputException(e.code, e.message!);
        default:
          print(e.code);
          print(e.message);
          print(e.details);
          print(e.stacktrace);
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
