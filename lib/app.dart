import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:GreenLens/configs/constant.dart';
import 'package:GreenLens/screens/splash_screen/splash_screen.dart';
import 'theme/themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
        builder: (context) => PlatformTheme(
            themeMode: ThemeMode.light,
            materialLightTheme: Themes.lightTheme,
            builder: (context) => PlatformApp(
              navigatorKey: AppConstants.navigatorKey,
              title: 'Flutter Demo',
              home: const SplashScreen(), // Entry screen
            )));
  }
}