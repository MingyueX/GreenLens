import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:ar_flutter_plugin/models/depth_img_array.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tree/screens/image_capture_page/image_capture_screen.dart';
import 'package:tree/image_processor_interface.dart';
import 'package:tree/img_result_provider.dart';
import 'package:tree/painter_on_image.dart';
import 'package:tree/utils/file_storage.dart';
import 'package:tree/utils/image_util.dart';
import 'dart:ui' as ui;

class CaptureConfirm extends StatelessWidget {
  const CaptureConfirm(
      {Key? key,
      required this.imageResult,
      required this.cameraImage,
      required this.captureHeight,
      required this.rawDepthArrays,
      required this.confidenceArrays})
      : super(key: key);

  final ImageResult imageResult;
  final CameraImage cameraImage;
  final double captureHeight;
  final DepthImgArrays? rawDepthArrays;
  final DepthImgArrays? confidenceArrays;

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
                  ? RawImage(
                      image: imageResult.displayImage!,
                    )
                  : const Text("No images"),
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Column(children: [
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
                  ElevatedButton(
                    onPressed: () async {
                      ui.Image image =
                          await ImageUtil.bytesToUiImage(cameraImage.bytes!);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              body: DraggableImagePainter(
                                image: image,
                                cameraImage: cameraImage,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Optimize"),
                  ),
                ])),
            Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<ImgResultProvider>(context, listen: false)
                        .imageResult = imageResult;
                    FileStorage.saveToFileResults(
                        elevation: captureHeight,
                        image: cameraImage.bytes!,
                        arrays: imageResult.depthImage!,
                        rawDepthArrays: rawDepthArrays,
                        confidenceArrays: confidenceArrays);
                    Navigator.of(context).maybePop();
                  },
                  child: const Text("Save"),
                ))
          ],
        ));
  }
}
