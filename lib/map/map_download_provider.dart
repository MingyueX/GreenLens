import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:GreenLens/map/region_mode.dart';

class DownloadProvider extends ChangeNotifier {
  RegionMode _regionMode = RegionMode.square;

  RegionMode get regionMode => _regionMode;

  set regionMode(RegionMode newMode) {
    _regionMode = newMode;
    notifyListeners();
  }

  BaseRegion? _region;

  BaseRegion? get region => _region;

  set region(BaseRegion? newRegion) {
    _region = newRegion;
    notifyListeners();
  }

  final StreamController<void> _manualPolygonRecalcTrigger =
  StreamController.broadcast();
  StreamController<void> get manualPolygonRecalcTrigger =>
      _manualPolygonRecalcTrigger;
  void triggerManualPolygonRecalc() => _manualPolygonRecalcTrigger.add(null);


  DownloadBufferMode _bufferMode = DownloadBufferMode.tiles;
  DownloadBufferMode get bufferMode => _bufferMode;
  set bufferMode(DownloadBufferMode newMode) {
    _bufferMode = newMode;
    _bufferingAmount = newMode == DownloadBufferMode.tiles ? 500 : 5000;
    notifyListeners();
  }

  int _bufferingAmount = 500;
  int get bufferingAmount => _bufferingAmount;
  set bufferingAmount(int newNum) {
    _bufferingAmount = newNum;
    notifyListeners();
  }
}