import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:tree/base/widgets/check_box.dart';
import 'package:tree/base/widgets/confirm_button.dart';
import 'package:tree/screens/image_capture_page/image_capture_screen.dart';
import 'package:tree/theme/colors.dart';

import '../../../../img_result_provider.dart';
import '../../../../model/models.dart';
import '../tree_page_viewmodel.dart';

class TreeCollectCard extends StatefulWidget {
  const TreeCollectCard({Key? key}) : super(key: key);

  @override
  State<TreeCollectCard> createState() => _TreeCollectCardState();
}

class _TreeCollectCardState extends State<TreeCollectCard> {
  static const double spacing = 15;

  TreeCondition selectedCondition = TreeCondition.alive;

  bool isDead = false;

  /// Alive
  TreeAliveCondition? _selectedAliveCondition;

  /// Dead
  PhysicalMechanism? _selectedPhysicalMechanism;
  NumTreesInMortality? _selectedNumTreesInMortality;
  KillProcess? _selectedKillProcess;

  final _latController = TextEditingController();
  final _longController = TextEditingController();
  final _diameterController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
    final viewModel = context.watch<TreePageViewModel>();

    final imageResult =
        Provider.of<ImgResultProvider>(context, listen: true).imageResult;
    if (imageResult != null) {
      _diameterController.text = imageResult.diameter.toStringAsFixed(2);
    }

    final List<DropdownMenuEntry<TreeAliveCondition>> conditionEntries =
        <DropdownMenuEntry<TreeAliveCondition>>[];
    for (final TreeAliveCondition condition in TreeAliveCondition.values) {
      conditionEntries.add(
        DropdownMenuEntry<TreeAliveCondition>(
            value: condition, label: condition.detail),
      );
    }

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
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Tree',
                    ),
                    TextSpan(
                        text: "#${viewModel.state.trees.length + 1}",
                        style: Theme.of(context).textTheme.labelMedium)
                  ],
                ),
              ),
              const SizedBox(height: spacing),
              Text("Condition",
                  style: Theme.of(context).textTheme.headlineMedium),
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
                activeBorders: [
                  Border.all(color: AppColors.baseWhite, width: 2)
                ],
                borderWidth: 1,
                initialLabelIndex: selectedCondition.index,
                labels: const ['ALIVE', 'NOT FOUND', 'NO LONGER EXIST'],
                onToggle: (index) {
                  setState(() {
                    switch (index) {
                      case 0:
                        selectedCondition = TreeCondition.alive;
                        break;
                      case 1:
                        selectedCondition = TreeCondition.notFound;
                        break;
                      case 2:
                        selectedCondition = TreeCondition.noLongerExist;
                        break;
                    }
                  });
                },
                customWidths: const [60, 90, 135],
                customTextStyles: const [
                  TextStyle(fontSize: 12.0),
                  TextStyle(fontSize: 12.0),
                  TextStyle(fontSize: 12.0),
                ],
              ),
              SizedBox(height: 12),
              if (selectedCondition == TreeCondition.alive)
                FormForAlive(
                  onDetailSelected: (condition) {
                    setState(() {
                      _selectedAliveCondition = condition;
                    });
                  },
                  onRefreshLocation: () async {
                    await _getLocation();
                  },
                  latController: _latController,
                  longController: _longController,
                  diameterController: _diameterController,
                  selectedAliveCondition: _selectedAliveCondition,
                ),
              if (selectedCondition == TreeCondition.noLongerExist)
                FormForNoExist(
                  onDeadChecked: (value) {
                    setState(() {
                      isDead = value;
                    });
                  },
                  isDead: isDead,
                  selectedPhysicalMechanism: _selectedPhysicalMechanism,
                  selectedNumTreesInMortality: _selectedNumTreesInMortality,
                  selectedKillProcess: _selectedKillProcess,
                  onPhysicalMechanismSelected: (mechanism) {
                    setState(() {
                      _selectedPhysicalMechanism = mechanism;
                    });
                  },
                  onNumTreesInMortalitySelected: (numTrees) {
                    setState(() {
                      _selectedNumTreesInMortality = numTrees;
                    });
                  },
                  onKillProcessSelected: (process) {
                    setState(() {
                      _selectedKillProcess = process;
                    });
                  },
                ),
              const SizedBox(height: spacing),
              ConfirmButton(
                onPressed: () {
                  if (_formKey.currentState == null ||
                      !_formKey.currentState!.validate()) {
                    return;
                  }
                  if (selectedCondition == TreeCondition.alive) {
                    Tree tree = Tree(
                        plotId: viewModel.state.plotId!,
                        locationLatitude: double.parse(_latController.text),
                        locationLongitude: double.parse(_longController.text),
                        isEucalyptus: true,
                        speciesId: 1,
                        condition: selectedCondition,
                        conditionDetail: _selectedAliveCondition,
                        diameter: double.parse(_diameterController.text));
                    viewModel.addTree(tree);
                  }
                  // TODO: Implement
                  else {
                    SnackBar snackBar = const SnackBar(
                      content: Text('Not implemented yet'),
                      duration: Duration(seconds: 1),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  Navigator.pop(context);
                },
                buttonPrompt: 'Save',
              )
            ],
          ),
        ));
  }
}

class FormForAlive extends StatelessWidget {
  const FormForAlive(
      {Key? key,
      required this.onDetailSelected,
      required this.onRefreshLocation,
      required this.latController,
      required this.longController,
      required this.diameterController,
      required this.selectedAliveCondition})
      : super(key: key);

  final TreeAliveCondition? selectedAliveCondition;
  final Function onDetailSelected;
  final Function onRefreshLocation;
  final TextEditingController latController;
  final TextEditingController longController;
  final TextEditingController diameterController;

  static const double spacing = 15;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown<TreeAliveCondition>(
          hint: "Select Condition Details",
          value: selectedAliveCondition,
          items: TreeAliveCondition.values,
          onChanged: (condition) {
            onDetailSelected(condition);
          },
          getItemLabel: (mechanism) => mechanism.detail,
        ),
        const SizedBox(height: spacing),
        Row(children: [
          Text("Location", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(width: 5),
          IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                await onRefreshLocation();
              },
              icon: const Icon(
                Icons.refresh,
                color: AppColors.primaryGreen,
              ))
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: PlatformTextFormField(
              controller: latController,
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
              controller: longController,
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
            Container(
                width: 195,
                height: 25,
                child: Stack(children: [
                  TextField(
                    controller: diameterController,
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
                              child: const Text("CAPTURE➜"))))
                ]))
          ],
        ),
        const SizedBox(height: spacing),
        Text("Species ID (not implemented)",
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: spacing),
        Text("Is Eucalyptus? (not implemented)",
            style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}

class FormForNoExist extends StatelessWidget {
  const FormForNoExist(
      {Key? key,
      required this.onDeadChecked,
      required this.isDead,
      required this.selectedPhysicalMechanism,
      required this.selectedNumTreesInMortality,
      required this.selectedKillProcess,
      required this.onPhysicalMechanismSelected,
      required this.onNumTreesInMortalitySelected,
      required this.onKillProcessSelected})
      : super(key: key);

  final bool isDead;
  final Function onDeadChecked;

  /// for dead trees
  final PhysicalMechanism? selectedPhysicalMechanism;
  final NumTreesInMortality? selectedNumTreesInMortality;
  final KillProcess? selectedKillProcess;
  final Function onPhysicalMechanismSelected;
  final Function onNumTreesInMortalitySelected;
  final Function onKillProcessSelected;

  static const double spacing = 15;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Is DEAD?",
                  style: Theme.of(context).textTheme.headlineMedium),
              CheckBoxWithText(
                  onChange: (value) {
                    onDeadChecked(value);
                  },
                  currentValue: isDead),
            ],
          ),
          if (isDead)
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: spacing),
                  Text("Mortality",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 5),
                  CustomDropdown<PhysicalMechanism>(
                    hint: "Select Physical Mechanism",
                    value: selectedPhysicalMechanism,
                    items: PhysicalMechanism.values,
                    onChanged: (mechanism) {
                      onPhysicalMechanismSelected(mechanism);
                    },
                    getItemLabel: (mechanism) => mechanism.detail,
                  ),
                  const SizedBox(height: spacing),
                  CustomDropdown<NumTreesInMortality>(
                    hint: "Select # Trees in Mortality",
                    value: selectedNumTreesInMortality,
                    items: NumTreesInMortality.values,
                    onChanged: (numTrees) {
                      onNumTreesInMortalitySelected(numTrees);
                    },
                    getItemLabel: (numTrees) => numTrees.detail,
                  ),
                  const SizedBox(height: spacing),
                  CustomDropdown<KillProcess>(
                    hint: "Select Kill Process",
                    value: selectedKillProcess,
                    items: KillProcess.values,
                    onChanged: (killProcess) {
                      onKillProcessSelected(killProcess);
                    },
                    getItemLabel: (killProcess) => killProcess.detail,
                  ),
                ])
        ]);
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T)? getItemLabel;

  const CustomDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.getItemLabel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      validator: (value) {
        if (value == null) {
          return 'Required';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        border:
            OutlineInputBorder(borderSide: BorderSide(color: AppColors.grey)),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: AppColors.grey)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: AppColors.grey)),
        contentPadding: EdgeInsets.only(left: 10),
      ),
      hint: Text(hint),
      menuMaxHeight: 250,
      focusColor: AppColors.primaryGreen,
      value: value,
      borderRadius: BorderRadius.circular(5),
      isExpanded: true,
      isDense: false,
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  getItemLabel!(e),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
