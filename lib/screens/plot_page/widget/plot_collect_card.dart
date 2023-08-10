import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tree/base/widgets/date.dart';
import 'package:tree/farmer_provider.dart';
import 'package:tree/screens/main_pages/plot_page/plot_page_viewmodel.dart';

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
  TextEditingController _clusterIdController = TextEditingController();
  TextEditingController _groupIdController = TextEditingController();
  TextEditingController _farmIdController = TextEditingController();

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
                  style:
                  Theme.of(context).textTheme.headlineLarge,
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Plot',
                    ),
                    TextSpan(
                        text: "#${viewModel.state.plots.length + 1}",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium)
                  ],
                ),
              ),
              const SizedBox(height: spacing),
              const CurrentDate(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: PlatformTextFormField(
                    controller: _clusterIdController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.start,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    material: (_, __) => MaterialTextFormFieldData(
                      decoration: const InputDecoration(
                        labelText: "Cluster ID",
                      ),
                    ),
                  )),
                  const SizedBox(width: 25),
                  Expanded(
                      child: PlatformTextFormField(
                    controller: _groupIdController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    controller: _farmIdController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                      return;
                    }
                    final farmerId =
                        Provider.of<FarmerProvider>(context, listen: false)
                            .farmer
                            .participantId;
                    Plot plot = Plot(
                        clusterId: int.parse(_clusterIdController.text),
                        groupId: int.parse(_groupIdController.text),
                        farmId: int.parse(_farmIdController.text),
                        harvesting: isHarvesting,
                        thinning: isThinning,
                        dominantLandUse: selectedLandUse!.name,
                        date: DateTime.now(),
                        farmerId: farmerId);
                    viewModel.addPlot(plot);
                    Navigator.pop(context);
                  },
                  child: Text("Save"))
            ],
          ),
        ));
  }
}
