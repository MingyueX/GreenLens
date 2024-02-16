import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:GreenLens/screens/map_downloader/widgets/cached_map.dart';
import 'package:GreenLens/screens/map_downloader/widgets/map_view.dart';
import 'package:GreenLens/screens/map_downloader/widgets/shape_options.dart';
import 'package:GreenLens/theme/colors.dart';
import 'package:GreenLens/theme/themes.dart';

import '../../configs/constant.dart';
import '../../map/map_download_provider.dart';

class DownloaderPage extends StatefulWidget {
  const DownloaderPage({super.key, required this.initialCenter});

  final LatLng initialCenter;

  @override
  State<DownloaderPage> createState() => _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  StreamSubscription<DownloadProgress>? _progressListener;
  double _downloadProgress = 0;
  bool _downloading = false;

  @override
  void dispose() {
    _progressListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryGreen,
          title: Container(
            padding: EdgeInsets.only(top: 20),
            alignment: Alignment.center,
            child: Text('Download the region selected?',
                style: Theme.of(context).textTheme.appbarTitle),
          ),
        ),
        body: Center(child: MapView(initialCenter: widget.initialCenter,)),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (_) => const ShapeControllerPopup(),
            ).then(
                  (_) => Provider.of<DownloadProvider>(context, listen: false)
                  .triggerManualPolygonRecalc(),
            );
          },
          child: const Icon(Icons.select_all),
        ),
        bottomNavigationBar: _downloading
            ? Container(
                alignment: Alignment.center,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: AppColors.baseWhite,
                child: LinearProgressIndicator(
                  value: _downloadProgress,
                ))
            : Consumer<DownloadProvider>(
                builder: (context, downloadProvider, _) => Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                          color: AppColors.primaryGreen,
                          child: TextButton(
                            onPressed: () {
                              downloadProvider.region == null
                                  ? () {}
                                  : setState(() {
                                      _downloading = true;
                                    });

                              _progressListener = FMTC
                                  .instance('mapStore')
                                  .download
                                  .startForeground(
                                    region:
                                        downloadProvider.region!.toDownloadable(
                                      10,
                                      22,
                                      TileLayer(
                                        urlTemplate:
                                            "https://api.mapbox.com/styles/v1/{mapBoxId}/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                                        additionalOptions: const {
                                          'mapBoxId': AppConstants.mapBoxId,
                                          'mapStyleId':
                                              AppConstants.mapBoxStyleId,
                                          'accessToken':
                                              AppConstants.mapBoxAccessToken,
                                        },
                                      ),
                                    ),
                                    bufferMode: DownloadBufferMode.tiles,
                                  )
                                  .listen((progress) {
                                print(progress.successfulTiles);
                                final percentage = (progress.successfulTiles /
                                        progress.maxTiles);
                                setState(() {
                                  _downloadProgress = percentage;
                                });

                                if (percentage == 1) {
                                  setState(() {
                                    _downloading = false;
                                  });
                                    AppConstants.navigatorKey.currentState!
                                        .push(
                                        MaterialPageRoute(
                                          builder: (_) => const CachedMap(),
                                        ));
                                }
                              });
                            },
                            child: const Text(
                              'DOWNLOAD',
                              style: TextStyle(
                                color: AppColors.baseWhite,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ))
                      ],
                    ))),
      );
}
