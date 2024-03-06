import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:GreenLens/image_processor/image_processor_interface.dart';

/// To be removed
class ImgResultProvider extends ChangeNotifier {
  ImageResult? _imageResult;

  String? _locationsJson;

  ImageResult? get imageResult => _imageResult;
  String? get locationsJson => _locationsJson;

  set imageResult(ImageResult? value) {
    _imageResult = value;
    notifyListeners();
  }

  set speciesImage(Uint8List? value) {
    notifyListeners();
  }

  set locationsJson(String? value) {
    _locationsJson = value;
    notifyListeners();
  }

  void clear() {
    _imageResult = null;
    notifyListeners();
  }
}