import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/image_capture_page/image_capture_screen.dart';
import '../../utils/arcore.dart';
import 'dialog.dart';

class ShortCutButton extends StatefulWidget {
  const ShortCutButton({Key? key}) : super(key: key);

  @override
  State<ShortCutButton> createState() => _ShortCutButtonState();
}

class _ShortCutButtonState extends State<ShortCutButton>{

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  // }
  //
  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     // Check if ARCore was installed after returning to the app.
  //     ARCoreService.checkAndPromptInstallation().then((isInstalled) {
  //       if (isInstalled) {
  //         // ARCore is installed, proceed with the app's flow.
  //       } else {
  //         // Handle the case where ARCore is still not installed.
  //       }
  //     });
  //   }
  // }

  void _handleARCoreCheck() async {
    try {
      bool isInstalled = await ARCoreService.checkArcore();

      if (isInstalled) {
        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ImageCaptureScreen()));
        }
      } else {
        if (mounted) {
          CustomDialog.show(context,
              dialogType: DialogType.doubleButton,
              message:
              'ARCORE is not installed on your device. Please install it to continue.',
              cancelText: 'Later',
              confirmText: 'Install Now',
              onConfirmed: () async {
                await ARCoreService.checkAndPromptInstallation();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ARCore failed or not supported on this device."),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      // onPressed: () async {
      //   bool isARCoreInstalled = await ARCoreService.checkAndPromptInstallation();
      //
      //   Navigator.of(context).push(MaterialPageRoute(
      //       builder: (context) =>
      //       const ImageCaptureScreen()));
      // },
      onPressed: _handleARCoreCheck,
      child: Icon(Icons.camera_alt),
    );
  }
}
