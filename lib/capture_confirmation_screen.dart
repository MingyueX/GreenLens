import 'package:flutter/material.dart';
import 'package:tree/image_processor_interface.dart';

class CaptureConfirm extends StatelessWidget {
  const CaptureConfirm({Key? key, required this.imageResult}) : super(key: key);

  final ImageResult imageResult;

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
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Re-capture"),
            )),
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
