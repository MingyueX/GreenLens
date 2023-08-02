import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tree/base/widgets/date.dart';

import '../../../model/models.dart';

class PlotCollectCard extends StatefulWidget {
  const PlotCollectCard({Key? key}) : super(key: key);

  @override
  State<PlotCollectCard> createState() => _PlotCollectCardState();
}

class _PlotCollectCardState extends State<PlotCollectCard> {
  bool isHarvesting = false;
  bool isThinning = false;
  LandUse? selectedLandUse = LandUse.water;

  static const double spacing = 15;

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CurrentDate(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: PlatformTextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.start,
                material: (_, __) => MaterialTextFormFieldData(
                  decoration: const InputDecoration(
                    labelText: "Cluster ID",
                  ),
                ),
              )),
              const SizedBox(width: 25),
              Expanded(
                  child: PlatformTextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.start,
                material: (_, __) => MaterialTextFormFieldData(
                  decoration: const InputDecoration(
                    labelText: "Group ID",
                  ),
                ),
              )),
              const SizedBox(width: 25),
              Expanded(
                  child: PlatformTextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.start,
                material: (_, __) => MaterialTextFormFieldData(
                  decoration: const InputDecoration(
                    labelText: "Farm ID",
                  ),
                ),
              ))
            ],
          ),
          const SizedBox(height: spacing),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Harvesting in progress?",
                style: Theme.of(context).textTheme.headlineMedium),
            Checkbox(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                fillColor: isHarvesting
                    ? MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary)
                    : null,
                value: isHarvesting,
                onChanged: (bool? value) {
                  setState(() {
                    isHarvesting = value!;
                  });
                })
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Thinning in progress?",
                style: Theme.of(context).textTheme.headlineMedium),
            Checkbox(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                fillColor: isThinning
                    ? MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary)
                    : null,
                value: isThinning,
                onChanged: (bool? value) {
                  setState(() {
                    isThinning = value!;
                  });
                })
          ]),
          const SizedBox(height: spacing),
          Text("Dominant land use surrounding the plot:",
              style: Theme.of(context).textTheme.headlineMedium),
          Wrap(
            spacing: 5, // space between the options
            runSpacing: 0, // space between the lines
            children: LandUse.values.map((LandUse usage) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<LandUse>(
                    fillColor: usage == selectedLandUse
                        ? MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primary)
                        : null,
                    value: usage,
                    groupValue: selectedLandUse,
                    onChanged: (LandUse? landUse) {
                      setState(() {
                        selectedLandUse = landUse;
                      });
                    },
                  ),
                  Text(usage.name), // Display the color name
                ],
              );
            }).toList(),
          )
        ],
      ),
    ));
  }
}
