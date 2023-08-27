import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../constant.dart';
import '../../../map/map_download_provider.dart';
import '../../../map/region_mode.dart';

class MapView extends StatefulWidget {
  const MapView({
    super.key,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const double _shapePadding = 15;

  final _mapKey = GlobalKey<State<StatefulWidget>>();
  final MapController _mapController = MapController();

  late final StreamSubscription _polygonVisualizerStream;
  late final StreamSubscription _manualPolygonRecalcTriggerStream;
  LatLng? _coordsTopLeft;
  LatLng? _coordsBottomRight;
  LatLng? _center;
  double? _radius;

  PolygonLayer _buildTargetPolygon(BaseRegion region) => PolygonLayer(
        polygons: [
          Polygon(
            points: [
              LatLng(-90, 180),
              LatLng(90, 180),
              LatLng(90, -180),
              LatLng(-90, -180),
            ],
            holePointsList: [region.toOutline()],
            isFilled: true,
            borderColor: Colors.black,
            borderStrokeWidth: 2,
            color: Theme.of(context).colorScheme.background.withOpacity(2 / 3),
          ),
        ],
      );

  @override
  void initState() {
    super.initState();

    _manualPolygonRecalcTriggerStream =
        Provider.of<DownloadProvider>(context, listen: false)
            .manualPolygonRecalcTrigger
            .stream
            .listen((_) {
      _updatePointLatLng();
    });

    _polygonVisualizerStream =
        _mapController.mapEventStream.listen((_) => _updatePointLatLng());
  }

  @override
  void dispose() {
    super.dispose();

    _polygonVisualizerStream.cancel();
    _manualPolygonRecalcTriggerStream.cancel();
  }

  @override
  Widget build(BuildContext context) => Consumer<DownloadProvider>(
        key: _mapKey,
        builder: (_, downloadProvider, __) => FutureBuilder<
                Map<String, String>?>(
            future: FMTC.instance('mapStore').metadata.readAsync,
            builder: (context, metadata) {
              final String? urlTemplate =
              metadata.data?['sourceURL'];

              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: LatLng(43.663250, -79.383610),
                      zoom: 15,
                      maxZoom: 22,
                      maxBounds: LatLngBounds.fromPoints([
                        LatLng(-90, 180),
                        LatLng(90, 180),
                        LatLng(90, -180),
                        LatLng(-90, -180),
                      ]),
                      interactiveFlags:
                          InteractiveFlag.all & ~InteractiveFlag.rotate,
                      scrollWheelVelocity: 0.002,
                      keepAlive: true,
                      onMapReady: () {
                        _updatePointLatLng();
                      },
                    ),
                    /*nonRotatedChildren: buildStdAttribution(
                        urlTemplate,
                        alignment: AttributionAlignment.bottomLeft,
                      ),*/
                    children: [
                      TileLayer(
                        urlTemplate: urlTemplate ??
                            "https://api.mapbox.com/styles/v1/{mapBoxId}/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                        additionalOptions: const {
                          'mapBoxId': AppConstants.mapBoxId,
                          'mapStyleId': AppConstants.mapBoxStyleId,
                          'accessToken': AppConstants.mapBoxAccessToken,
                        },
                        maxNativeZoom: 22,
                        maxZoom: 22,
                        keepBuffer: 5,
                        backgroundColor: const Color(0xFFaad3df),
                      ),
                      if (_coordsTopLeft != null &&
                          _coordsBottomRight != null &&
                          downloadProvider.regionMode != RegionMode.circle)
                        _buildTargetPolygon(
                          RectangleRegion(
                            LatLngBounds(_coordsTopLeft!, _coordsBottomRight!),
                          ),
                        )
                      else if (_center != null &&
                          _radius != null &&
                          downloadProvider.regionMode == RegionMode.circle)
                        _buildTargetPolygon(CircleRegion(_center!, _radius!))
                    ],
                  ),
                ],
              );
            }),
      );

  void _updatePointLatLng() {
    final DownloadProvider downloadProvider =
        Provider.of<DownloadProvider>(context, listen: false);

    final Size mapSize = _mapKey.currentContext!.size!;
    final bool isHeightLongestSide = mapSize.width < mapSize.height;

    final centerNormal = Point<double>(mapSize.width / 2, mapSize.height / 2);
    final centerInversed = Point<double>(mapSize.height / 2, mapSize.width / 2);

    late final Point<double> calculatedTopLeft;
    late final Point<double> calculatedBottomRight;

    switch (downloadProvider.regionMode) {
      case RegionMode.square:
        final double offset = (mapSize.shortestSide - (_shapePadding * 2)) / 2;

        calculatedTopLeft = Point<double>(
          centerNormal.x - offset,
          centerNormal.y - offset,
        );
        calculatedBottomRight = Point<double>(
          centerNormal.x + offset,
          centerNormal.y + offset,
        );
        break;
      case RegionMode.rectangleVertical:
        final allowedArea = Size(
          mapSize.width - (_shapePadding * 2),
          (mapSize.height - (_shapePadding * 2)) / 1.5 - 50,
        );

        calculatedTopLeft = Point<double>(
          centerInversed.y - allowedArea.shortestSide / 2,
          _shapePadding,
        );
        calculatedBottomRight = Point<double>(
          centerInversed.y + allowedArea.shortestSide / 2,
          mapSize.height - _shapePadding - 25,
        );
        break;
      case RegionMode.rectangleHorizontal:
        final allowedArea = Size(
          mapSize.width - (_shapePadding * 2),
          (mapSize.width < mapSize.height + 250)
              ? (mapSize.width - (_shapePadding * 2)) / 1.75
              : (mapSize.height - (_shapePadding * 2) - 0),
        );

        calculatedTopLeft = Point<double>(
          _shapePadding,
          centerNormal.y - allowedArea.height / 2,
        );
        calculatedBottomRight = Point<double>(
          mapSize.width - _shapePadding,
          centerNormal.y + allowedArea.height / 2 - 25,
        );
        break;
      case RegionMode.circle:
        final allowedArea =
            Size.square(mapSize.shortestSide - (_shapePadding * 2));

        final calculatedTop = Point<double>(
          centerNormal.x,
          (isHeightLongestSide ? centerNormal.y : centerInversed.x) -
              allowedArea.width / 2,
        );

        _center =
            _mapController.pointToLatLng(_customPointFromPoint(centerNormal));
        _radius = const Distance(roundResult: false).distance(
              _center!,
              _mapController
                  .pointToLatLng(_customPointFromPoint(calculatedTop))!,
            ) /
            1000;
        setState(() {});
        break;
    }

    if (downloadProvider.regionMode != RegionMode.circle) {
      _coordsTopLeft = _mapController
          .pointToLatLng(_customPointFromPoint(calculatedTopLeft));
      _coordsBottomRight = _mapController
          .pointToLatLng(_customPointFromPoint(calculatedBottomRight));

      setState(() {});
    }

    downloadProvider.region = downloadProvider.regionMode == RegionMode.circle
        ? CircleRegion(_center!, _radius!)
        : RectangleRegion(
            LatLngBounds(_coordsTopLeft!, _coordsBottomRight!),
          );
  }
}

CustomPoint<E> _customPointFromPoint<E extends num>(Point<E> point) =>
    CustomPoint(point.x, point.y);
