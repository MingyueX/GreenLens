import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:GreenLens/base/custom_route.dart';

enum DialogType { singleButton, doubleButton }

class CustomDialog {
  static dialogWidget(context,
      {String? message,
        String? title,
        Function? onConfirmed,
        Function? onCanceled,
        String? confirmText,
        String? cancelText,
        required DialogType dialogType}) =>
      PlatformAlertDialog(
        title: title != null ? Text(title) : null,
        content: message != null ? Text(message) : null,
        actions: [
          if (dialogType == DialogType.doubleButton)
            PlatformDialogAction(
                child: Text(cancelText ?? "Cancel"),
                onPressed: () {
                  if (onCanceled != null) {
                    onCanceled();
                  }
                  Navigator.of(context).pop();
                }),
          PlatformDialogAction(
            child: Text(confirmText ?? "OK"),
            onPressed: () => onConfirmed != null
                ? onConfirmed()
                : Navigator.of(context).pop(),
          ),
        ],
      );

  static void show(BuildContext context,
      {String? message,
        String? title,
        Function? onConfirmed,
        Function? onCanceled,
        String? confirmText,
        String? cancelText,
        required DialogType dialogType}) {
    if (title != null || message != null) {
      Navigator.of(context).push(CustomRoute(
          builder: (context) => dialogWidget(context,
              message: message,
              title: title,
              onConfirmed: onConfirmed,
              onCanceled: onCanceled,
              confirmText: confirmText,
              cancelText: cancelText,
              dialogType: dialogType)));
    }
  }
}