import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:tree/base/widgets/plain_button.dart';
import 'package:tree/screens/image_capture_page/image_capture_screen.dart';
import 'package:tree/theme/colors.dart';

import '../../../img_result_provider.dart';
import '../../../model/models.dart';

class TreeCollectCard extends StatefulWidget {
  const TreeCollectCard({Key? key}) : super(key: key);

  @override
  State<TreeCollectCard> createState() => _TreeCollectCardState();
}

class _TreeCollectCardState extends State<TreeCollectCard> {
  static const double spacing = 15;

  TreeAliveCondition? selectedCondition;
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  final _diameterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  _getLocation() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      // Request permission
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(2);
        _longController.text = position.longitude.toStringAsFixed(2);
      });
    } else {
      // TODO: Handle the case when permission is not granted
      print('Location permission not granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageResult = Provider.of<ImgResultProvider>(context).imageResult;

    final List<DropdownMenuEntry<TreeAliveCondition>> conditionEntries =
        <DropdownMenuEntry<TreeAliveCondition>>[];
    for (final TreeAliveCondition condition in TreeAliveCondition.values) {
      conditionEntries.add(
        DropdownMenuEntry<TreeAliveCondition>(
            value: condition, label: condition.detail),
      );
    }

    return Form(
        child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Condition", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 5),
          ToggleSwitch(
            minWidth: 285,
            minHeight: 25,
            cornerRadius: 5,
            borderColor: const [AppColors.grey],
            inactiveBgColor: AppColors.baseWhite,
            inactiveFgColor: AppColors.grey,
            activeBgColor: const [AppColors.primaryGreen],
            dividerColor: AppColors.grey,
            activeBorders: [Border.all(color: AppColors.baseWhite, width: 2)],
            borderWidth: 1,
            labels: const ['ALIVE', 'NOT FOUND', 'NO LONGER EXIST'],
            customWidths: const [60, 90, 135],
            customTextStyles: const [
              TextStyle(fontSize: 12.0),
              TextStyle(fontSize: 12.0),
              TextStyle(fontSize: 12.0),
            ],
          ),
          SizedBox(height: 12),
          DropdownButtonFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey)),
                  contentPadding: EdgeInsets.only(left: 10)),
              hint: Text("Select Condition Details"),
              menuMaxHeight: 250,
              focusColor: AppColors.primaryGreen,
              value: selectedCondition,
              borderRadius: BorderRadius.circular(5),
              isExpanded: true,
              isDense: false,
              items: TreeAliveCondition.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.detail,
                        ),
                      ))
                  .toList(),
              onChanged: (condition) {
                setState(() {
                  selectedCondition = condition;
                });
              }),
          const SizedBox(height: spacing),
          Text("Location", style: Theme.of(context).textTheme.headlineMedium),
          /*const SizedBox(height: spacing),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: PlatformTextFormField(
                controller: _latController,
                enabled: false,
                textAlign: TextAlign.start,
                material: (_, __) => MaterialTextFormFieldData(
                  decoration: const InputDecoration(
                    labelText: "Latitude",
                  ),
                ),
              )),
              const SizedBox(width: 25),
              Expanded(
                  child: PlatformTextFormField(
                controller: _longController,
                enabled: false,
                textAlign: TextAlign.start,
                material: (_, __) => MaterialTextFormFieldData(
                  decoration: const InputDecoration(
                    labelText: "Longitude",
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: spacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Diameter(m)",
                  style: Theme.of(context).textTheme.headlineMedium),
              /*Container(
                  width: 185,
                  height: 25,
                  child: Stack(children: [
                    TextField(
                      controller: _diameterController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey)),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const ImageCaptureScreen()));
                                },
                                child: Text(
                                  imageResult == null
                                      ? "CAPTURE➜"
                                      : "RE-CAPTURE➜",
                                ))))
                  ]))*/
              if (imageResult != null)
                Text(imageResult.diameter.toStringAsFixed(2)),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ImageCaptureScreen()));
                  },
                  child: Text(
                    imageResult == null ? "CAPTURE➜" : "RE-CAPTURE➜",
                  ))
            ],
          ),
          const SizedBox(height: spacing),
        ],
      ),
    ));
  }
}
