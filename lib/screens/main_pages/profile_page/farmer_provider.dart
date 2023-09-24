import 'package:flutter/material.dart';

import '../../../model/models.dart';

class FarmerProvider extends ChangeNotifier {
  late Farmer _farmer;
  Farmer get farmer => _farmer;

  Future<void> setFarmer(Farmer farmer) async {
    _farmer = farmer;
    notifyListeners();
  }
}