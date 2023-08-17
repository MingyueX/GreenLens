import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tree/img_result_provider.dart';
import 'package:tree/screens/main_pages/plot_page/plot_page_viewmodel.dart';
import 'package:tree/screens/main_pages/tree_page/tree_page_viewmodel.dart';
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
        BlocProvider<TreePageViewModel>(create: (_) => TreePageViewModel()),
      ], child: const MyApp())));
}
