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
import '../main_pages/profile_page/farmer_provider.dart';

class CaptureConfirm extends StatelessWidget {
  CaptureConfirm(
      {Key? key,
      required this.imageResult,
      required this.cameraImage,
      // required this.captureHeight,
      required this.rawDepthArrays,
      required this.confidenceArrays,
      required this.locations,
      required this.lineJson,
      required this.diameter})
      : super(key: key);

  final ImageResult imageResult;
  final CameraImage cameraImage;
  // final double captureHeight;
  final DepthImgArrays? rawDepthArrays;
  final DepthImgArrays? confidenceArrays;
  final List<Position> locations;
  final double diameter;
  final String lineJson;

  final CloudStorage cloudStorage = CloudStorage();

  @override
  Widget build(BuildContext context) {
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
                              builder: (context) => const ImageCaptureScreen(),
                            ),
                          );
                        },
                        child: const Text("Re-capture"),
                      ),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     ui.Image image = await ImageUtil.bytesToUiImage(
                      //         cameraImage.bytes!);
                      //     if (context.mounted) {
                      //       Navigator.of(context).push(
                      //         MaterialPageRoute(
                      //           builder: (context) => Scaffold(
                      //             body: DraggableImagePainter(
                      //               image: image,
                      //               cameraImage: cameraImage,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   },
                      //   child: const Text("Optimize"),
                      // ),
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
                        "Please retake when the lines don’t fit well with the edges."))),
            Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    Uint8List imageBytes = imageResult.rgbImage!;
                    Farmer currentUser = Provider
                        .of<FarmerProvider>(context, listen: false)
                        .farmer;
                    String fileName = await CloudStorage.getFileName();
                    String path = "image/${currentUser == null ? "unknown" : "#${currentUser.participantId}_${currentUser.name}/"}diameter_capture/";
                    String result = await cloudStorage.uploadImage(imageBytes, fileName, path);
                    if (result.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          Provider.of<ImgResultProvider>(context, listen: false).imageResult = imageResult;
                          Provider.of<ImgResultProvider>(context, listen: false).cloudImageUrl = result;
                          Navigator.of(context).maybePop();
                        }
                      });
                    }



                    // final String? userInput = await showDialog<String>(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     TextEditingController controller =
                    //         TextEditingController();
                    //     return AlertDialog(
                    //       title: Text("Enter a number"),
                    //       content: TextField(
                    //         controller: controller,
                    //         keyboardType: TextInputType.number,
                    //         decoration:
                    //             InputDecoration(hintText: "Enter a number"),
                    //       ),
                    //       actions: [
                    //         TextButton(
                    //           child: Text("Cancel"),
                    //           onPressed: () {
                    //             Navigator.of(context).pop(); // close the dialog
                    //           },
                    //         ),
                    //         TextButton(
                    //           child: Text("OK"),
                    //           onPressed: () {
                    //             Navigator.of(context).pop(controller
                    //                 .text); // close the dialog and return the input value
                    //           },
                    //         ),
                    //       ],
                    //     );
                    //   },
                    // );

                    // FileStorage.saveToFileResults(
                    //     // elevation: captureHeight,
                    //     estDiameter: diameter,
                    //     image: cameraImage.bytes!,
                    //     arrays: imageResult.depthImage!,
                    //     rawDepthArrays: rawDepthArrays,
                    //     confidenceArrays: confidenceArrays);

                    // if (userInput != null &&
                    //     userInput.isNotEmpty &&
                    //     context.mounted) {
                    //   FileStorage.saveToFileResults(
                    //       elevation: captureHeight,
                    //       image: cameraImage.bytes!,
                    //       arrays: imageResult.depthImage!,
                    //       rawDepthArrays: rawDepthArrays,
                    //       confidenceArrays: confidenceArrays,
                    //       groundTruth: userInput);

                  },
                  child: const Text("Save"),
                ))
          ],
        ));
  }
}
