import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tree/screens/main_pages/tree_page/img_result_provider.dart';
import 'package:tree/screens/main_pages/plot_page/plot_page_viewmodel.dart';
import 'package:tree/screens/main_pages/tree_page/tree_page_viewmodel.dart';
import 'package:tree/utils/camera.dart';
import 'dart:io';

import 'app.dart';
import 'screens/main_pages/profile_page/farmer_provider.dart';
import 'configs/firebase_options.dart';
import 'map/map_download_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  await FMTC.instance('mapStore').manage.createAsync();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final cameras = await availableCameras();
  CameraUtil.camera = cameras.first;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        ChangeNotifierProvider<FarmerProvider>(create: (_) => FarmerProvider()),
        ChangeNotifierProvider<DownloadProvider>(
          create: (context) => DownloadProvider(),
        ),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider<PlotPageViewModel>(create: (_) => PlotPageViewModel()),
        BlocProvider<TreePageViewModel>(create: (_) => TreePageViewModel()),
      ], child: const MyApp())));
}
