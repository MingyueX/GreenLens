import 'dart:convert';

import 'package:GreenLens/screens/image_capture_page/optimize_with_parallel.dart';
import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:ar_flutter_plugin/models/depth_img_array.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:GreenLens/screens/image_capture_page/image_capture_screen.dart';
import 'package:GreenLens/image_processor/image_processor_interface.dart';
import 'package:GreenLens/screens/main_pages/tree_page/img_result_provider.dart';
import 'package:GreenLens/utils/file_storage.dart';
import 'dart:ui' as ui;

import '../../base/widgets/toast_like_msg.dart';
import '../../model/models.dart';
import '../../services/cloud/cloud_storage.dart';
import '../../utils/image_util.dart';
import '../main_pages/profile_page/farmer_provider.dart';

class CaptureConfirm extends StatelessWidget {

  CaptureConfirm(
      {Key? key,
      required this.onImgSaved,
      required this.imageResult,
      required this.cameraImage,
      required this.focalLength,
      // required this.rawDepthArrays,
      // required this.confidenceArrays,
      required this.locations,
      required this.lineJson,
      required this.diameter})
      : super(key: key);

  final Function(String) onImgSaved;
  final ImageResult imageResult;
  final CameraImage cameraImage;
  final double focalLength;
  // final DepthImgArrays? rawDepthArrays;
  // final DepthImgArrays? confidenceArrays;
  final List<Position> locations;
  final double diameter;
  final String lineJson;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          return true;
        },
        child: Stack(
          children: [
            Center(
              child: imageResult.displayImage != null
                  ? imageResult.displayImage!
                  // ? RawImage(
                  //     image: imageResult.displayImage!,
                  //   )
                  : const Text("No images"),
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ImageCaptureScreen(onImgSaved: onImgSaved),
                            ),
                          );
                        },
                        child: const Text("Re-capture"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          ui.Image image = await ImageUtil.bytesToUiImage(
                              cameraImage.bytes!);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  body: InteractiveLinesWidget(
                                    image: image, cameraImage: cameraImage, linesJson: json.decode(lineJson), imageResult: imageResult, focalLength: focalLength, onImgSaved: onImgSaved,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text("Optimize"),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text("DBH: ${diameter.toStringAsFixed(2)}",
                              style: Theme.of(context).textTheme.labelLarge)),
                    ])),
            const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                    child: ToastLikeMsg(
                        msg:
                        "Please retake/optimize when the lines don’t fit well with the edges."))),
            Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    onImgSaved(imageResult.diameter.toStringAsFixed(2));
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                        if (context.mounted) {
                          Provider.of<ImgResultProvider>(context, listen: false).imageResult = imageResult;
                          Navigator.of(context).popUntil(ModalRoute.withName("/treeCollectionPage"));
                        }
                      });
                  },
                  child: const Text("Save"),
                ))
          ],
        ));
  }
}
