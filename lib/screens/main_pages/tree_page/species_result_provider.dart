import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class SpeciesResultProvider extends ChangeNotifier {
  String? speciesName;
  Uint8List? _speciesImage;

  String? get name => speciesName;
  Uint8List? get speciesImage => _speciesImage;

  set speciesImage(Uint8List? value) {
    _speciesImage = value;
    notifyListeners();
  }

  set name(String? name) {
    speciesName = name;
    notifyListeners();
  }

  void clear() {
    speciesName = null;
    _speciesImage = null;
    notifyListeners();
  }
}