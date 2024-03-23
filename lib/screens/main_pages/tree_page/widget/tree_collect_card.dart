import 'dart:io';

import 'package:GreenLens/screens/main_pages/tree_page/species_result_provider.dart';
import 'package:GreenLens/screens/species_identify/camera_page.dart';
import 'package:ar_flutter_plugin/models/depth_img_array.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:GreenLens/base/widgets/check_box.dart';
import 'package:GreenLens/base/widgets/confirm_button.dart';
import 'package:GreenLens/screens/image_capture_page/image_capture_screen.dart';
import 'package:GreenLens/theme/colors.dart';
import 'package:GreenLens/utils/location.dart';

import '../../../../base/widgets/dialog.dart';
import '../../../../utils/arcore.dart';
import '../../../../utils/file_storage.dart';
import '../../profile_page/farmer_provider.dart';
import '../img_result_provider.dart';
import '../../../../model/models.dart';
import '../tree_page_viewmodel.dart';

class TreeCollectCard extends StatefulWidget {
  const TreeCollectCard({Key? key, this.tree}) : super(key: key);

  final Tree? tree;

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
  final _ageController = TextEditingController();
  final _speciesController = TextEditingController();
  final _idController = TextEditingController();

  Uint8List? _diameterImage;
  Uint8List? _speciesImage;
  DepthImgArrays? _depthData;
  String? _captureLocations;
  String? _lineJson;

  bool isEucalyptus = false;
  bool enableCustomizeLocation = false;

  final _formKey = GlobalKey<FormState>();

  final myLocPlugin = LocationFlutterPlugin();

  @override
  void initState() {

    myLocPlugin.setAgreePrivacy(true);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      PermissionStatus status = await Permission.locationWhenInUse.status;

      if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
        // Request permission
        status = await Permission.locationWhenInUse.request();
      }

      if (status.isGranted) {
        await _getLocation();
      }
    });

    // _getLocation();
    if (widget.tree != null) {
      isEucalyptus = widget.tree!.isEucalyptus;
      _diameterController.text = widget.tree!.diameter != null ? widget.tree!.diameter.toString() : "";
      _ageController.text = widget.tree!.age != null ? widget.tree!.age.toString() : "";
      _speciesController.text = widget.tree!.species != null ? widget.tree!.species! : "";
      _idController.text = widget.tree!.uid != null ? widget.tree!.uid.toString() : "";
      selectedCondition = widget.tree!.condition;
      isDead = widget.tree!.physicalMechanism != null;
      if (selectedCondition == TreeCondition.alive) {
        _selectedAliveCondition = widget.tree!.conditionDetail;
      }
      if (isDead) {
        _selectedPhysicalMechanism = widget.tree!.physicalMechanism;
        _selectedNumTreesInMortality = widget.tree!.numTreesInMortality;
        _selectedKillProcess = widget.tree!.killProcess;
      }
    }
    super.initState();
  }

  BaiduLocationAndroidOption initAndroidOptions() {
    BaiduLocationAndroidOption options =
    BaiduLocationAndroidOption(
    locationMode: BMFLocationMode.hightAccuracy,
// 坐标系
    coordType: BMFLocationCoordType.bd09ll,
// 设置发起定位请求的间隔，int类型，单位ms
// 如果设置为0，则代表单次定位，即仅定位一次，默认为0
    scanspan: 0);
    return options;
  }

  BaiduLocationIOSOption initIOSOptions() {
    BaiduLocationIOSOption options =
    BaiduLocationIOSOption(
        coordType: BMFLocationCoordType.bd09ll,
    );
    return options;
  }

  _getLocation() async {
    print("Getting location");
    Map iosMap = initIOSOptions().getMap();
    Map androidMap = initAndroidOptions().getMap();

    await myLocPlugin.prepareLoc(androidMap, iosMap);

    await myLocPlugin.startLocation();

    myLocPlugin.singleLocationCallback(callback: (BaiduLocation result) {
      print("Location: ${result.longitude}, ${result.latitude}");
      if (result.longitude != null && result.latitude != null) {
        _latController.text = result.latitude!.toStringAsFixed(2);
        _longController.text = result.longitude!.toStringAsFixed(2);
      } else {
        enableCustomizeLocation = true;
        // showSnakbar
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to get location, please input manually"),
            ));
      }
      myLocPlugin.stopLocation();
    });
    // LocationUtil.getLocation().then((value) {
    //   if (value != null) {
    //     _latController.text = value.latitude.toStringAsFixed(2);
    //     _longController.text = value.longitude.toStringAsFixed(2);
    //   } else {
    //     enableCustomizeLocation = true;
    //     // showSnakbar
    //     ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Failed to get location, please input manually"),
    //     ));
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TreePageViewModel>();

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
                  children: const <TextSpan>[
                    TextSpan(
                      text: 'New Tree',
                    ),
                    // TextSpan(
                    //     text: "#${viewModel.state.trees.length + 1}",
                    //     style: Theme.of(context).textTheme.labelMedium)
                  ],
                ),
              ),
              const SizedBox(height: spacing),
              SizedBox(
                  width: 60,
                  child:
                  PlatformTextFormField(
                    controller: _idController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.start,
                    material: (_, __) => MaterialTextFormFieldData(
                      decoration: const InputDecoration(
                        labelText: "ID",
                      ),
                    ),
                  )),
              // Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //
              //       Text("Id",
              //           style: Theme.of(context).textTheme.headlineMedium),
              //       Container(
              //           width: 195,
              //           height: 25,
              //           child: TextField(
              //             controller: _idController,
              //             keyboardType: TextInputType.number,
              //             decoration: const InputDecoration(
              //               border: OutlineInputBorder(
              //                   borderSide: BorderSide(color: AppColors.grey)),
              //               enabledBorder: OutlineInputBorder(
              //                   borderSide: BorderSide(color: AppColors.grey)),
              //               focusedBorder: OutlineInputBorder(
              //                   borderSide: BorderSide(color: AppColors.grey)),
              //             ),))]),
              const SizedBox(height: spacing),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Is Eucalyptus?",
                    style: Theme.of(context).textTheme.headlineMedium),
                CheckBoxWithText(
                    onChange: (bool value) {
                      setState(() {
                        isEucalyptus = value;
                      });
                    },
                    currentValue: isEucalyptus)
              ]),
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
                  enableLocationInput: enableCustomizeLocation,
                  latController: _latController,
                  longController: _longController,
                  diameterController: _diameterController,
                  ageController: _ageController,
                  speciesController: _speciesController,
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
                onPressed: () async {
                  if (_formKey.currentState == null ||
                      !_formKey.currentState!.validate()) {
                    return;
                  }
                  Farmer? currentUser;
                  if (context.mounted) {
                    currentUser = Provider
                        .of<FarmerProvider>(context, listen: false)
                        .farmer;
                    final imageResult =
                        Provider
                            .of<ImgResultProvider>(context, listen: false)
                            .imageResult;
                    if (imageResult != null) {
                      _diameterImage = imageResult.rgbImage;
                      _lineJson = imageResult.lineJson;
                      _depthData = imageResult.depthImage;
                    }
                    final speciesImage =
                        Provider
                            .of<SpeciesResultProvider>(context, listen: false)
                            .speciesImage;
                    if (speciesImage != null) {
                      _speciesImage = speciesImage;
                    }

                    final locationsJson =
                        Provider
                            .of<ImgResultProvider>(context, listen: false)
                            .locationsJson;
                    if (locationsJson != null) {
                      _captureLocations = locationsJson;
                    }
                  }
                  if (selectedCondition == TreeCondition.alive) {
                    Tree tree = Tree(
                      id: widget.tree != null ? widget.tree!.id : null,
                        plotId: widget.tree != null ? widget.tree!.plotId : viewModel.state.plotId!,
                        locationLatitude: double.parse(_latController.text),
                        locationLongitude: double.parse(_longController.text),
                        isEucalyptus: isEucalyptus,
                        speciesId: 1,
                        condition: selectedCondition,
                        conditionDetail: _selectedAliveCondition,
                        diameter: _diameterController.text.isEmpty ? null : double.parse(_diameterController.text),
                        age: _ageController.text.isEmpty ? null : double.parse(_ageController.text),
                        species: _speciesController.text,
                        locationsJson: _captureLocations,
                        lineJson: _lineJson,
                        uid: _idController.text.isEmpty ? null : int.parse(_idController.text),
                    );
                    if (selectedCondition == TreeCondition.noLongerExist) {
                      tree = Tree(
                        id: widget.tree != null ? widget.tree!.id : null,
                        plotId: widget.tree != null ? widget.tree!.plotId : viewModel.state.plotId!,
                        locationLatitude: double.parse(_latController.text),
                        locationLongitude: double.parse(_longController.text),
                        isEucalyptus: isEucalyptus,
                        condition: selectedCondition,
                        physicalMechanism: _selectedPhysicalMechanism,
                        numTreesInMortality: _selectedNumTreesInMortality,
                        killProcess: _selectedKillProcess,
                        uid: _idController.text.isEmpty ? null : int.parse(_idController.text),
                      );
                    }
                    int? treeId;
                    // user is editing
                    if (widget.tree != null) {
                      print('tree details: ${tree.toString()}');
                      await viewModel.updateTree(tree);
                      treeId = tree.id;
                    }
                    else {
                      await viewModel.addTree(tree);
                      treeId = viewModel.state.treeId;
                    }
                    String basePath = await FileStorage.getBasePath();
                    if (_diameterImage != null) {
                      String diameterPath = '$basePath/Participant#${currentUser == null ? "unknown" : "${currentUser.participantId}"}/Plot#${tree.plotId}/Tree#$treeId${tree.uid == null ? "" : "_${tree.uid}"}/diameter_capture.jpg';
                      final diameterFile = File(diameterPath);
                      await diameterFile.parent.create(recursive: true);
                      await diameterFile.writeAsBytes(_diameterImage!);
                    }
                    if (_speciesImage != null) {
                      String speciesPath = '$basePath/Participant#${currentUser == null ? "unknown" : "${currentUser.participantId}"}/Plot#${tree.plotId}/Tree#$treeId${tree.uid == null ? "" : "_${tree.uid}"}/species_capture.jpg';
                      final speciesFile = File(speciesPath);
                      await speciesFile.parent.create(recursive: true);
                      await speciesFile.writeAsBytes(_speciesImage!);
                    }
                    if (_depthData != null) {
                      String depthDataPath = '$basePath/Participant#${currentUser == null ? "unknown" : "${currentUser.participantId}"}/Plot#${tree.plotId}/Tree#$treeId${tree.uid == null ? "" : "_${tree.uid}"}/depth_data';
                      final buffer = StringBuffer();
                      for (int i = 0; i < _depthData!.length; i++) {
                        buffer.write('${_depthData!.xBuffer[i]},');
                        buffer.write('${_depthData!.yBuffer[i]},');
                        buffer.write('${_depthData!.dBuffer[i]},');
                        buffer.write('${_depthData!.percentageBuffer[i]}\n');
                      }
                      final depthFile = File(depthDataPath);
                      await depthFile.parent.create(recursive: true);
                      await depthFile.writeAsString(buffer.toString());
                    }
                  }
                  // TODO: Implement
                  else {
                    SnackBar snackBar = const SnackBar(
                      content: Text('Not implemented yet'),
                      duration: Duration(seconds: 1),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  if (context.mounted) {
                    Provider.of<ImgResultProvider>(context, listen: false).clear();
                    Provider.of<SpeciesResultProvider>(context, listen: false).clear();
                    Navigator.pop(context);
                  }
                },
                buttonPrompt: 'Save',
              )
            ],
          ),
        ));
  }
}

class FormForAlive extends StatelessWidget {
  const FormForAlive({Key? key,
    required this.onDetailSelected,
    required this.onRefreshLocation,
    required this.latController,
    required this.longController,
    required this.enableLocationInput,
    required this.diameterController,
    required this.selectedAliveCondition,
    required this.speciesController,
    required this.ageController})
      : super(key: key);

  final TreeAliveCondition? selectedAliveCondition;
  final Function onDetailSelected;
  final Function onRefreshLocation;
  final bool enableLocationInput;
  final TextEditingController latController;
  final TextEditingController longController;
  final TextEditingController diameterController;
  final TextEditingController ageController;
  final TextEditingController speciesController;

  static const double spacing = 15;

  void _handleARCoreCheck(BuildContext context) async {
    try {
      bool isInstalled = await ARCoreService.checkArcore();

      if (isInstalled) {
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ImageCaptureScreen(onImgSaved: (diameter) {
                diameterController.text = diameter;
              },)));
        }
      } else {
        if (context.mounted) {
          CustomDialog.show(context,
              dialogType: DialogType.doubleButton,
              message:
              'ARCORE is not installed on your device. Please install it to continue.',
              cancelText: 'Later',
              confirmText: 'Install Now',
              onConfirmed: () async {
                await ARCoreService.checkAndPromptInstallation();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ARCore failed or not supported on this device."),
        ),
      );
    }
  }

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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter latitude';
                    }
                    return null;
                  },
              controller: latController,
              enabled: enableLocationInput,
              keyboardType: TextInputType.number,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter longitude';
                    }
                    return null;
                  },
              controller: longController,
              enabled: enableLocationInput,
              keyboardType: TextInputType.number,
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
              Text("Age",
                  style: Theme.of(context).textTheme.headlineMedium),
              Container(
                  width: 195,
                  height: 25,
                  child: TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey)),
                    ),))]),
        const SizedBox(height: spacing),
        // Consumer<SpeciesResultProvider>(
        //     builder: (context, speciesProvider, child) {
        //       speciesController.text = speciesProvider.speciesName ?? "";
        //       return
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Species",
                        style: Theme.of(context).textTheme.headlineMedium),
                    Container(
                        width: 195,
                        height: 25,
                        child: Stack(children: [
                          TextField(
                            controller: speciesController,
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
                                            builder: (context) => TakePictureScreen(
                                              onImgSaved: (speciesName) {
                                                speciesController.text = speciesName;
                                              },
                                            )));
                                      },
                                      child: const Text("SCAN➜"))))
                        ]))
                  ],
                ),
        const SizedBox(height: spacing),
        // Consumer<ImgResultProvider>(
        //     builder: (context, imgProvider, child) {
        //       diameterController.text = imgProvider.imageResult?.diameter.toString() ?? "";
        //       return
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
                                    // onPressed: () {
                                    //   Navigator.of(context).push(MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           const ImageCaptureScreen()));
                                    // },
                                      onPressed: () {
                                        _handleARCoreCheck(context);
                                      },
                                      child: const Text("CAPTURE➜"))))
                        ]))
                  ],
                ),
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
