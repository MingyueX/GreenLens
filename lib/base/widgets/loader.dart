import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class Loader {
  static loaderWidget(context, {double? paddingTop}) => Stack(
    alignment: Alignment.center,
    children: [
      Positioned(
        top: paddingTop ?? MediaQuery.of(context).size.height / 2,
        child: const CircularProgressIndicator(),
      ),
    ],
  );

  static void show(BuildContext context,
      {double? paddingTop, String? message}) {
    showPlatformDialog(
        context: context,
        builder: (context) => loaderWidget(context, paddingTop: paddingTop));
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}