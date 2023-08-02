import 'package:ar_flutter_plugin/models/ar_image.dart';
import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:flutter/material.dart';
import 'package:tree/image_processor_interface.dart';
import 'package:tree/painter_on_image.dart';

class CaptureConfirm extends StatelessWidget {
  const CaptureConfirm(
      {Key? key,
      required this.imageResult,
      required this.cameraImage,
      required this.arImage})
      : super(key: key);

  final ImageResult imageResult;
  final CameraImage cameraImage;
  final ARImage arImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  Navigator.of(context).pop();
                },
                child: const Text("Re-capture"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        body: DraggableImagePainter(cameraImage: cameraImage,),
                      ),
                    ),
                  );
                },
                child: const Text("Optimize"),
              ),
            ])),
        Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Save"),
            ))
      ],
    );
  }
}
