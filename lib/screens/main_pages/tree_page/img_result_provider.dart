import 'package:flutter/cupertino.dart';
import 'package:GreenLens/image_processor/image_processor_interface.dart';

/// To be removed
class ImgResultProvider extends ChangeNotifier {
  ImageResult? _imageResult;
  String? _cloudImageUrl;
  String? _locationsJson;

  ImageResult? get imageResult => _imageResult;
  String? get cloudImageUrl => _cloudImageUrl;
  String? get locationsJson => _locationsJson;

  set imageResult(ImageResult? value) {
    _imageResult = value;
    notifyListeners();
  }

  set cloudImageUrl(String? value) {
    _cloudImageUrl = value;
    notifyListeners();
  }

  set locationsJson(String? value) {
    _locationsJson = value;
    notifyListeners();
  }

  void clear() {
    _imageResult = null;
    // _cloudImageUrl = null;
    // _locationsJson = null;
    notifyListeners();
  }
}