import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

import '../../../constant.dart';

class CachedMap extends StatefulWidget {
  const CachedMap({Key? key}) : super(key: key);

  @override
  State<CachedMap> createState() => _CachedMapState();
}

class _CachedMapState extends State<CachedMap> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(43.663250, -79.383610),
        minZoom: 5,
        maxZoom: 22,
        zoom: 15,
      ),
      children: [
        TileLayer(
          evictErrorTileStrategy: EvictErrorTileStrategy.notVisible,
          urlTemplate:
          "https://api.mapbox.com/styles/v1/{mapBoxId}/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
          additionalOptions: const {
            'mapBoxId' : AppConstants.mapBoxId,
            'mapStyleId': AppConstants.mapBoxStyleId,
            'accessToken': AppConstants.mapBoxAccessToken,
          },
          tileProvider: FMTC.instance('mapStore').getTileProvider(
            FMTCTileProviderSettings(
              behavior: CacheBehavior.cacheOnly,
            )
          ),

          maxNativeZoom: 22,
          maxZoom: 22,
        ),
      ],
    );
  }
}
