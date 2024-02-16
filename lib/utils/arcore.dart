import 'package:flutter/services.dart';

const String ARCORE_CHANNEL = "com.example.tree/arcore"; // Use the actual channel name.

class ARCoreService {
  static const MethodChannel _channel = MethodChannel(ARCORE_CHANNEL);

  static Future<bool> checkAndPromptInstallation() async {
    try {
      final bool isInstalled = await _channel.invokeMethod('arcore_installation');
      return isInstalled;
    } on PlatformException catch (e) {
      print("Failed to check ARCore installation: ${e.message}");
      return false;
    }
  }

  static Future<bool> checkArcore() async {
    try {
      final bool isInstalled = await _channel.invokeMethod('arcore_check');
      return isInstalled;
    } on PlatformException catch (e) {
      rethrow;
    }
  }

}
