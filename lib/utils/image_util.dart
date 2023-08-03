import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ar_flutter_plugin/models/camera_image.dart';

class ImageUtil {
  static Future<ui.Image> decodeImageFromList(
      Uint8List imageBytes, int width, int height) {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromPixels(imageBytes, width, height, ui.PixelFormat.rgba8888,
        (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  static Future<ui.Image> cameraImageToUiImage(CameraImage cameraImage) async {
    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(
      cameraImage.bytes!,
      (ui.Image img) {
        completer.complete(img);
      },
    );

    return completer.future;
  }
}
