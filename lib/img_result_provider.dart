import 'package:flutter/cupertino.dart';
import 'package:tree/image_processor_interface.dart';

class ImgResultProvider extends ChangeNotifier {
  ImageResult? _imageResult;

  ImageResult? get imageResult => _imageResult;

  set imageResult(ImageResult? value) {
    _imageResult = value;
    notifyListeners();
  }
}