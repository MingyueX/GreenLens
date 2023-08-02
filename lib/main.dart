import 'package:flutter/material.dart';
import 'package:tree/model/models.dart';
import 'package:tree/services/storage/db_service.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  await dbService.clear();

  Farmer farmer = Farmer(
    name: "Miranda",
    participantId: 1);

  Plot plot = Plot(farmerId: 1, clusterId: 1, groupId: 1, farmId: 1, date: DateTime.now(), harvesting: false, thinning: false, dominantLandUse: LandUse.bare.name);

  await dbService.insertFarmer(farmer);
  await dbService.insertPlot(plot);

  runApp(const MyApp());
}