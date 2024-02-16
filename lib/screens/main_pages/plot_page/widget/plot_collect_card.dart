import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:GreenLens/base/widgets/check_box.dart';
import 'package:GreenLens/base/widgets/date.dart';
import 'package:GreenLens/screens/main_pages/profile_page/farmer_provider.dart';
import 'package:GreenLens/screens/main_pages/plot_page/plot_page_viewmodel.dart';
import 'package:GreenLens/theme/colors.dart';

import '../../../../base/widgets/confirm_button.dart';
import '../../../../model/models.dart';

class PlotCollectCard extends StatefulWidget {
  const PlotCollectCard({Key? key}) : super(key: key);

  @override
  State<PlotCollectCard> createState() => _PlotCollectCardState();
}

class _PlotCollectCardState extends State<PlotCollectCard> {
  bool isHarvesting = false;
  bool isThinning = false;
  LandUse? selectedLandUse = LandUse.water;
  // final TextEditingController _clusterIdController = TextEditingController();
  // final TextEditingController _groupIdController = TextEditingController();
  // final TextEditingController _farmIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  static const double spacing = 15;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlotPageViewModel>();

    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineLarge,
                  children: const <TextSpan>[
                    TextSpan(
                      text: 'New Plot',
                    ),
                    // TODO: review after confirmed plot id
                    /*TextSpan(
                        text: "#${viewModel.state.plots.length + 1}",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium)*/
                  ],
                ),
              ),
              const SizedBox(height: spacing),
              const CurrentDate(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Expanded(
              //         child: PlatformTextFormField(
              //       controller: _clusterIdController,
              //       keyboardType: TextInputType.number,
              //       textAlign: TextAlign.start,
              //       validator: (value) {
              //         if (value == null || value.isEmpty) {
              //           return "Required";
              //         }
              //         return null;
              //       },
              //       autovalidateMode: AutovalidateMode.onUserInteraction,
              //       material: (_, __) => MaterialTextFormFieldData(
              //         decoration: const InputDecoration(
              //           labelText: "Cluster ID",
              //         ),
              //       ),
              //     )),
              //     const SizedBox(width: 25),
              //     Expanded(
              //         child: PlatformTextFormField(
              //       controller: _groupIdController,
              //       validator: (value) {
              //         if (value == null || value.isEmpty) {
              //           return "Required";
              //         }
              //         return null;
              //       },
              //       autovalidateMode: AutovalidateMode.onUserInteraction,
              //       keyboardType: TextInputType.number,
              //       textAlign: TextAlign.start,
              //       material: (_, __) => MaterialTextFormFieldData(
              //         decoration: const InputDecoration(
              //           labelText: "Group ID",
              //         ),
              //       ),
              //     )),
              //     const SizedBox(width: 25),
              //     Expanded(
              //         child: PlatformTextFormField(
              //       controller: _farmIdController,
              //       validator: (value) {
              //         if (value == null || value.isEmpty) {
              //           return "Required";
              //         }
              //         return null;
              //       },
              //       autovalidateMode: AutovalidateMode.onUserInteraction,
              //       keyboardType: TextInputType.number,
              //       textAlign: TextAlign.start,
              //       material: (_, __) => MaterialTextFormFieldData(
              //         decoration: const InputDecoration(
              //           labelText: "Farm ID",
              //         ),
              //       ),
              //     ))
              //   ],
              // ),
              const SizedBox(height: spacing),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Harvesting in progress?",
                    style: Theme.of(context).textTheme.headlineMedium),
                CheckBoxWithText(
                    onChange: (bool value) {
                      setState(() {
                        isHarvesting = value;
                      });
                    },
                    currentValue: isHarvesting)
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Thinning in progress?",
                    style: Theme.of(context).textTheme.headlineMedium),
                CheckBoxWithText(
                    onChange: (bool value) {
                      setState(() {
                        isThinning = value;
                      });
                    },
                    currentValue: isThinning)
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
              ),
              ConfirmButton(
                onPressed: () {
                  if (_formKey.currentState == null ||
                      !_formKey.currentState!.validate()) {
                    return;
                  }
                  final farmerId =
                      Provider.of<FarmerProvider>(context, listen: false)
                          .farmer
                          .participantId;
                  Plot plot = Plot(
                      // clusterId: int.parse(_clusterIdController.text),
                      // groupId: int.parse(_groupIdController.text),
                      // farmId: int.parse(_farmIdController.text),
                      clusterId: 1,
                      groupId: 1,
                      farmId: 1,
                      harvesting: isHarvesting,
                      thinning: isThinning,
                      dominantLandUse: selectedLandUse!.name,
                      date: DateTime.now(),
                      farmerId: farmerId);
                  viewModel.addPlot(plot);
                  Navigator.pop(context);
                },
                buttonPrompt: "Save",
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    height: 40.0,
                    alignment: Alignment.center,
                    child: Text(
                      "Cancel",
                      style: Theme.of(context).textTheme.headlineMedium,
                    )),
              )
            ],
          ),
        ));
  }
}
