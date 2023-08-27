import 'package:flutter/material.dart';

import '../../screens/image_capture_page/image_capture_screen.dart';

class ShortCutButton extends StatelessWidget {
  const ShortCutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
            const ImageCaptureScreen()));
      },
      child: Icon(Icons.camera_alt),
    );
  }
}
