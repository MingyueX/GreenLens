import 'dart:convert';

import 'package:GreenLens/services/cloud/cloud_storage.dart';
import 'package:ar_flutter_plugin/models/depth_img_array.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/image_capture_page/image_capture_screen.dart';
import '../../utils/arcore.dart';
import '../../utils/exceptions.dart';
import '../../utils/file_storage.dart';
import 'dialog.dart';

class ShortCutButton extends StatefulWidget {
  const ShortCutButton({Key? key}) : super(key: key);

  @override
  State<ShortCutButton> createState() => _ShortCutButtonState();
}

class _ShortCutButtonState extends State<ShortCutButton>{

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

  Future<void> _processImage(String s,
      BuildContext context) async {

    final FirebaseStorage storage = FirebaseStorage.instance;
    final ref1 = storage.ref().child("Tree$s").child("diameter_capture.jpg");
    final ref2 = storage.ref().child("Tree$s").child("depth_data");

    final String data = await ref2.getData().then((bytes) => String.fromCharCodes(bytes!));

    List<int> xBuffer = [];
    List<int> yBuffer = [];
    List<double> dBuffer = [];
    List<double> percentageBuffer = [];

    // Split the data into lines
    final lines = data.split('\n');
    for (var line in lines) {
      final parts = line.split(',');
      if (parts.length < 4) {
        print('Invalid line format: $line');
        continue; // Skip lines that don't have exactly 4 parts.
      }
      // Parse each part and add to buffers
      xBuffer.add(int.parse(parts[0]));
      yBuffer.add(int.parse(parts[1]));
      dBuffer.add(double.parse(parts[2]));
      percentageBuffer.add(double.parse(parts[3]));
    }

    final depthImgArray =  DepthImgArrays(
      xBuffer: xBuffer,
      yBuffer: yBuffer,
      dBuffer: dBuffer,
      percentageBuffer: percentageBuffer,
      length: xBuffer.length,
    );

    final Uint8List? rgbMat = await ref1.getData();

    _showLoadingDialog(context);
    try {
      const MethodChannel _channel = MethodChannel('com.example.tree/torch_model');

      final Map<String, dynamic> params = {
        'rgbMat': rgbMat,
        'depthArr': depthImgArray.dBuffer,
      };

      final result = await _channel.invokeMethod('process_image_debug', params);

      Map<String, dynamic> resultMap = jsonDecode(result);

      String imgBase64 = resultMap['img'];
      double preDBH = resultMap['pre_DBH'];
      String line = resultMap['line_json'];
      String depthBase64 = resultMap['depth'];
      String bgrBase64 = resultMap['bgr'];
      String filterDepthImgBase64 = resultMap['filter_depth_img'];
      String resBase64 = resultMap['res'];
      String resNewBase64 = resultMap['res_new'];

      Uint8List resultImg = base64Decode(imgBase64);
      Uint8List depthImg = base64Decode(depthBase64);
      Uint8List bgrImg = base64Decode(bgrBase64);
      Uint8List filterDepthImg = base64Decode(filterDepthImgBase64);
      Uint8List resImg = base64Decode(resBase64);
      Uint8List resNewImg = base64Decode(resNewBase64);

      String path = await FileStorage.getBasePath();
      path = '$path/Tree$s';
      FileStorage.saveToFileRGB(null, resultImg, '$path/result.jpg');
      FileStorage.saveToFileRGB(null, depthImg, '$path/depth.jpg');
      FileStorage.saveToFileRGB(null, bgrImg, '$path/bgr.jpg');
      FileStorage.saveToFileRGB(null, filterDepthImg, '$path/filter_depth.jpg');
      FileStorage.saveToFileRGB(null, resImg, '$path/res.jpg');
      FileStorage.saveToFileRGB(null, resNewImg, '$path/res_new.jpg');
      FileStorage.saveFile(preDBH.toString(), '$path/preDBH.txt');
      FileStorage.saveFile(line, '$path/line.json');

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


  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        for (int i = 2; i <= 14; i++) {
          if (i != 4) {
            await _processImage(i.toString(), context);
          }
        }
      },
      child: Icon(Icons.upload_file),
    );
  }
}
