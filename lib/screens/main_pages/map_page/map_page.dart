import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:GreenLens/base/widgets/app_bar.dart';
import 'package:GreenLens/configs/constant.dart';
import 'package:GreenLens/theme/themes.dart';

import '../../../theme/colors.dart';
import '../../../utils/location.dart';
import '../../map_downloader/map_downloader.dart';

// TODO: handle the case when location permission is not granted
class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  StreamSubscription<Position>? positionStream;
  Position? _currentPosition;
  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          CustomAppBar(title: 'Maps', actions: {Icons.download: () {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => DownloaderPage(initialCenter: mapController.center,)));
          }
          }),
      body:
      _currentPosition == null
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              minZoom: 5,
              maxZoom: 22,
              zoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/{mapBoxId}/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                additionalOptions: const {
                  'mapBoxId' : AppConstants.mapBoxId,
                  'mapStyleId': AppConstants.mapBoxStyleId,
                  'accessToken': AppConstants.mapBoxAccessToken,
                },
                maxNativeZoom: 22,
                maxZoom: 22,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    builder: (ctx) => Container(
                      child: const Icon(
                        Icons.radio_button_checked,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ));
    /*MapboxMap(
      myLocationEnabled: true,
      styleString: "mapbox://styles/mira0221/clloq8gfs00cu01qx2ee5elc5",
      accessToken: AppConstants.mapBoxAccessToken,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
        target: LatLng(
            _currentPosition!.latitude, _currentPosition!.longitude),
    zoom: 13.0,
    ),
      onStyleLoadedCallback: _onStyleLoadedCallback,
      minMaxZoomPreference: const MinMaxZoomPreference(5, 22),
    );*/
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    positionStream = Geolocator.getPositionStream(locationSettings: const LocationSettings()).listen(
          (Position position) {
        setState(() {
          _currentPosition = position;
        });
      },
    );
  }

  _getLocation() async {
    LocationUtil.getLocation().then((value) {
      if (value == null) return;
      // TODO: handle null value (when user deny location permission)
      setState(() {
        _currentPosition = value;
      });
    });
  }
}
