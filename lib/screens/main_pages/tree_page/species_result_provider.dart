import 'package:flutter/cupertino.dart';

class SpeciesResultProvider extends ChangeNotifier {
  String? speciesName;
  String? imgUrl;

  String? get name => speciesName;
  String? get imageUrl => imgUrl;

  set imageUrl(String? imageUrl) {
    imgUrl = imageUrl;
    notifyListeners();
  }

  set name(String? name) {
    speciesName = name;
    notifyListeners();
  }

  void clear() {
    speciesName = null;
    // imgUrl = null;
    notifyListeners();
  }
}