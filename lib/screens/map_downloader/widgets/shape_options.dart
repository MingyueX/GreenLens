import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../map/map_download_provider.dart';
import '../../../map/region_mode.dart';

class ShapeControllerPopup extends StatelessWidget {
  const ShapeControllerPopup({super.key});

  static const Map<String, List<dynamic>> regionShapes = {
    'Square': [
      Icons.crop_square_sharp,
      RegionMode.square,
    ],
    'Rectangle (Vertical)': [
      Icons.crop_portrait_sharp,
      RegionMode.rectangleVertical,
    ],
    'Rectangle (Horizontal)': [
      Icons.crop_landscape_sharp,
      RegionMode.rectangleHorizontal,
    ],
    'Circle': [
      Icons.circle_outlined,
      RegionMode.circle,
    ],
  };

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Consumer<DownloadProvider>(
      builder: (context, provider, _) => ListView.builder(
        itemCount: regionShapes.length,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          final String key = regionShapes.keys.toList()[i];
          final IconData icon = regionShapes.values.toList()[i][0];
          final RegionMode? mode = regionShapes.values.toList()[i][1];

          return ListTile(
            visualDensity: VisualDensity.compact,
            title: Text(key),
            leading: Icon(icon),
            trailing:
            provider.regionMode == mode ? const Icon(Icons.done) : null,
            onTap: () {
              provider.regionMode = mode!;
              Navigator.of(context).pop();
            },
          );
        },
      ),
    ),
  );
}