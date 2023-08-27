import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationUtil {
  static Future<Position?> getLocation() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      // Request permission
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return position;
    } else {
      // TODO: Handle the case when permission is not granted
      print('Location permission not granted');
      return null;
    }
  }
}