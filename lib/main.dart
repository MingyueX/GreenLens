import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tree/img_result_provider.dart';
import 'package:tree/model/models.dart';
import 'package:tree/screens/main_pages/plot_page/plot_page_viewmodel.dart';
import 'package:tree/services/storage/db_service.dart';
import 'dart:io';

import 'app.dart';
import 'farmer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final dbService = DatabaseService();
  await dbService.clear();

  Farmer farmer = Farmer(name: "Miranda", participantId: 1);

  Plot plot = Plot(
      farmerId: 1,
      clusterId: 1,
      groupId: 1,
      farmId: 1,
      date: DateTime.now(),
      harvesting: false,
      thinning: false,
      dominantLandUse: LandUse.bare.name);

  await dbService.insertFarmer(farmer);
  await dbService.insertPlot(plot);

  final appDocDir = await getApplicationDocumentsDirectory();
  final file = File('${appDocDir.path}/map_pin.glb');

  if (!await file.exists()) {
    final byteData = await rootBundle.load('assets/map_pin.glb');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<ImgResultProvider>(
            create: (_) => ImgResultProvider()),
        ChangeNotifierProvider<FarmerProvider>(create: (_) => FarmerProvider())
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider<PlotPageViewModel>(create: (_) => PlotPageViewModel()),
      ], child: const MyApp())));
}
