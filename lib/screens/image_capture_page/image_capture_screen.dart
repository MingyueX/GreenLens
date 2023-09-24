import 'dart:async';
import 'dart:ui' as ui;

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_image.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tree/base/widgets/dialog.dart';
import 'package:tree/base/widgets/toast_like_msg.dart';
import 'package:tree/screens/image_capture_page/capture_confirmation_screen.dart';
import 'package:tree/screens/image_capture_page/widget/position_verifier.dart';
import 'package:tree/theme/colors.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../image_processor/image_processor.dart';
import '../../image_processor/image_processor_interface.dart';
import 'optimize_paint_on_image.dart';
import '../../utils/exceptions.dart';
import '../../utils/image_util.dart';

class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({Key? key}) : super(key: key);

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen>
    with SingleTickerProviderStateMixin {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  // for perpendicular position verification
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  List<double>? _accelerometerValues;
  bool _inGoodRange = false;
  final double _threshold = 1;

  // for anchor placement and elevation detection
  ARNode? _localObjectNode;
  ARAnchor? _anchor;
  double? elevation;
  Timer? elevationTimer;
  final qualityValueNotifier = ValueNotifier<double>(0.0);

  // for guide flow
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _streamSubscriptions.add(
      accelerometerEvents.listen(
            (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            _inGoodRange =
                event.z.abs() < _threshold && event.y.abs() < _threshold;
          });
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support accelerometer Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );

    startElevationTimer();
  }

  void startElevationTimer() {
    elevationTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) async {
          if (_anchor != null) {
            double? newElevation = await getElevationFromAnchor(_anchor!);
            // Check if the elevation has changed
            if (newElevation != elevation) {
              // Update the state if it has
              setState(() {
                elevation = newElevation;
              });
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            return true;
          },
          child: Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ARView(
                  onARViewCreated: onARViewCreated,
                  planeDetectionConfig: PlaneDetectionConfig
                      .horizontalAndVertical,
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _currentStep == 0
                            ? ElevatedButton(
                          onPressed: () async {
                            _currentStep++;
                          },
                          child: const Text("Motion Completed"),
                        )
                            : _currentStep == 1 && _anchor == null
                            ? const ToastLikeMsg(
                            msg:
                            "Tap any point on the ground to place an anchor")
                            : _currentStep == 1 && _anchor != null
                            ? ElevatedButton(
                          onPressed: () async {
                            _currentStep++;
                            _arSessionManager!.onPlaneOrPointTap =
                                (list) {};
                            _arSessionManager!.startFetchingImages();
                            _arSessionManager!.depthQualityStream
                                .listen((result) async {
                              qualityValueNotifier.value = result;
                            });
                          },
                          child: const Text("Anchor Placed"),
                        )
                            : _currentStep == 2 && _inGoodRange
                            ? ElevatedButton(
                          onPressed: () async {
                            await onCaptureImage(context);
                          },
                          child: const Text("Capture"),
                        )
                            : Container())),
                if (_anchor != null)
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 15, left: 15),
                          child: ToastLikeMsg(
                              msg:
                              "Elevation: ${elevation?.toStringAsFixed(3) ??
                                  0.0}",
                              backgroundColor: AppColors.grey.withOpacity(0.5),
                              textStyle:
                              Theme
                                  .of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                color: AppColors.baseBlack,
                              )))),
                if (_currentStep == 2)
                  ValueListenableBuilder<double>(
                    valueListenable: qualityValueNotifier,
                    builder: (context, qualityValue, child) {
                      return PositionVerifier(
                        qualityValue: qualityValue,
                        inGoodRange: _inGoodRange,
                        accelerometerValues: _accelerometerValues,
                      );
                    },
                  )
              ],
            ),
          ),
        ));
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
            (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      if (_anchor != null && _localObjectNode != null) {
        await _arObjectManager!.removeNode(_localObjectNode!);
        await _arAnchorManager!.removeAnchor(_anchor!);
      }

      var newAnchor =
      ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await _arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor!) {
        _anchor = newAnchor;
        var newNode = ARNode(
            name: 'ground',
            type: NodeType.fileSystemAppFolderGLB,
            scale: Vector3(0.2, 0.2, 0.2),
            position: Vector3(0.0, 0.0, 0.0),
            rotation: Vector4(1.0, 0.0, 0.0, 0.0),
            uri: 'map_pin.glb');
        bool? didAddNodeToAnchor =
        await _arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
        if (didAddNodeToAnchor!) {
          _localObjectNode = newNode;
        } else {
          _arSessionManager!.onError("Adding Node to Anchor failed");
        }
      } else {
        _arSessionManager!.onError("Adding Anchor failed");
      }
    }
  }

  Future<double?> getElevationFromAnchor(ARAnchor anchor) async {
    Matrix4? cameraPose = await _arSessionManager!.getCameraPose();
    Matrix4? anchorPose = await _arSessionManager!.getPose(anchor);
    Vector3? cameraTranslation = cameraPose?.getTranslation();
    Vector3? anchorTranslation = anchorPose?.getTranslation();
    if (anchorTranslation != null && cameraTranslation != null) {
      return cameraTranslation.y - anchorTranslation.y; // Elevation difference
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    elevationTimer?.cancel();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    if (_arSessionManager != null) {
      _arSessionManager!.stopFetchingImages();
      _arSessionManager!.dispose();
    }
    super.dispose();
  }

  void onARViewCreated(ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;

    _arSessionManager!.onInitialize(
        showFeaturePoints: false,
        showPlanes: false,
        showWorldOrigin: false,
        showAnimatedGuide: true);
    _arObjectManager!.onInitialize();

    _arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
  }

  Future<void> onCaptureImage(BuildContext context) async {
    _arSessionManager!.stopFetchingImages();
    CameraImage imgRGB = await _arSessionManager!.getCameraImage();
    ARImage arImage = await _arSessionManager!.getDepthImage();

    ImageRaw imageRaw = ImageRaw(
        rgbMat: imgRGB.bytes,
        rgbWidth: imgRGB.width!,
        rgbHeight: imgRGB.height!,
        arMat: arImage.depthImgArrays,
        arWidth: arImage.width!,
        arHeight: arImage.height!);

    ImageProcessor imageProcessor = ImageProcessor();
    ImageResult? imageResult;
    if (mounted) {
      try {
        final result = await imageProcessor.processImage(context, imageRaw);
        imageResult = result['imageResult'];
        final diameter = result['diameter'];
        if (mounted && imageResult != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) =>
                    CaptureConfirm(
                      imageResult: imageResult!,
                      cameraImage: imgRGB,
                      captureHeight: elevation!,
                      rawDepthArrays: arImage.rawDepthImgArrays,
                      confidenceArrays: arImage.confidenceImgArrays,
                      diameter: diameter,
                    )),
            /*RawDepthTest(
                    cameraImg: imgRGB.bytes!,
                    depthImg: arImage.depthImgBytes!,
                    rawDepthImg: arImage.rawDepthImgBytes!,
                    confidenceImg: arImage.confidenceImgBytes!,
                    width: arImage.width!,
                    height: arImage.height!)),*/
          );
        }
      } catch (e) {
        if (e is ImageProcessException) {
          print(e.msg); // error occurred during image processing
        } else if (e is NeedManualInputException) {
          CustomDialog.show(context, dialogType: DialogType.doubleButton, message: '${e.cause} Please re-capture or manually input the edges to continue.',
              cancelText: 'Re-capture',
              confirmText: 'Manually Input',
              onConfirmed: () async {
                ui.Image image =
                await ImageUtil.bytesToUiImage(imgRGB.bytes!);

                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          Scaffold(
                            body: DraggableImagePainter(
                              image: image,
                              cameraImage: imgRGB,
                            ),
                          ),
                    ),
                  );
                }
              },
              onCanceled: () {
                _arSessionManager!.startFetchingImages();
              }
          );
        } else {
          print(e);
        }
      }
    }

    /// for depthImg evaluation
    /*final evaluateResult = await DepthEvaluator().evaluateDepth(imageRaw);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              Scaffold(
                body: Center(
                  child: Text(evaluateResult),
                ),
        ),
      ));
    }*/
  }
}