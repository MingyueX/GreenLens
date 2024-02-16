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
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:GreenLens/base/widgets/dialog.dart';
import 'package:GreenLens/base/widgets/toast_like_msg.dart';
import 'package:GreenLens/screens/image_capture_page/capture_confirmation_screen.dart';
import 'package:GreenLens/screens/image_capture_page/widget/position_verifier.dart';
import 'package:GreenLens/theme/colors.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../image_processor/image_processor.dart';
import '../../image_processor/image_processor_interface.dart';
import '../../utils/exceptions.dart';
import '../../utils/location.dart';

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
  final List<Position> _locations = [];
  Timer? _locationTimer;
  final int _updateIntervalSeconds = 1;

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
  StreamSubscription? _qualitySubscription;
  final qualityValueNotifier = ValueNotifier<double>(0.0);

  // for guide flow
  int _currentStep = 0;

  // for tracking progress
  StreamSubscription? _progressSubscription;
  int _progress = 0;

  bool _isProcessingTap = false;

  bool _isRetrial = false;

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
    startLocationUpdates();
  }

  void startLocationUpdates() async {
    // Start a timer that triggers getLocation() every second.
    _locationTimer = Timer.periodic(Duration(seconds: _updateIntervalSeconds), (Timer timer) async {
      Position? position = await LocationUtil.getLocation();
      if (position != null) {
        setState(() {
          _locations.add(position);
        });
      }
    });
  }

  void stopLocationUpdates() {
    _locationTimer?.cancel();
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
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                    child: _currentStep == 0
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.baseBlack.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Move your device",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _progress / 100,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tracking ${_progress}%',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    )
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     _currentStep++;
                    //   },
                    //   child: const Text("Motion Completed"),
                    // )
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
                                      _qualitySubscription = _arSessionManager!
                                          .depthQualityStream
                                          .listen((result) async {
                                        print("Received quality value: $result");
                                        qualityValueNotifier.value = result;
                                      },
                                          onError: (error) {
                                            print("Error in stream: $error");
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
            // if (_anchor != null)
            //   Align(
            //       alignment: Alignment.topLeft,
            //       child: Padding(
            //           padding: const EdgeInsets.only(top: 15, left: 15),
            //           child: ToastLikeMsg(
            //               msg:
            //                   "Elevation: ${elevation?.toStringAsFixed(3) ?? 0.0}",
            //               backgroundColor: AppColors.grey.withOpacity(0.5),
            //               textStyle:
            //                   Theme.of(context).textTheme.labelLarge?.copyWith(
            //                         color: AppColors.baseBlack,
            //                       )))),
            if (_currentStep == 2)
              ValueListenableBuilder<double>(
                valueListenable: qualityValueNotifier,
                builder: (context, qualityValue, child) {
                  return PositionVerifier(
                    qualityValue: _isRetrial ? null : qualityValue,
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

  // Future<void> onPlaneOrPointTapped(
  //     List<ARHitTestResult> hitTestResults) async {
  //   if (_isProcessingTap) {
  //     print("Still processing previous tap");
  //     return;
  //   }
  //   _isProcessingTap = true;
  //   var singleHitTestResult = hitTestResults.firstWhere(
  //       (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
  //   if (singleHitTestResult != null) {
  //     if (_anchor != null && _localObjectNode != null) {
  //       await _arObjectManager!.removeNode(_localObjectNode!);
  //       await _arAnchorManager!.removeAnchor(_anchor!);
  //       _anchor = null;
  //       _localObjectNode = null;
  //       await Future.delayed(Duration(milliseconds: 100));
  //     }
  //
  //     var newAnchor =
  //         ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
  //     bool? didAddAnchor = await _arAnchorManager!.addAnchor(newAnchor);
  //     if (didAddAnchor!) {
  //       _anchor = newAnchor;
  //       var newNode = ARNode(
  //           name: 'ground',
  //           type: NodeType.fileSystemAppFolderGLB,
  //           scale: Vector3(0.2, 0.2, 0.2),
  //           position: Vector3(0.0, 0.0, 0.0),
  //           rotation: Vector4(1.0, 0.0, 0.0, 0.0),
  //           uri: 'map_pin.glb');
  //       bool? didAddNodeToAnchor =
  //           await _arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
  //       if (didAddNodeToAnchor!) {
  //         _localObjectNode = newNode;
  //       } else {
  //         _arSessionManager!.onError("Adding Node to Anchor failed");
  //       }
  //     } else {
  //       _arSessionManager!.onError("Adding Anchor failed");
  //     }
  //   }
  //
  //   _isProcessingTap = false;
  // }

  Future<void> safelyRemoveOldItems() async {
    if (_localObjectNode != null ) {
      await _arObjectManager!.removeNode(_localObjectNode!);
      _localObjectNode = null;
    }

    if (_anchor != null) {
      await _arAnchorManager!.removeAnchor(_anchor!);
      _anchor = null;
    }
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    if (_isProcessingTap) {
      print("Still processing previous tap");
      return;
    }
    _isProcessingTap = true;

    try {
      var singleHitTestResult = hitTestResults.firstWhere(
              (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane,); // added fallback to return null if not found

      if (singleHitTestResult == null) {
        print("No suitable hitTestResult found");
        _isProcessingTap = false;
        return;
      }

      await safelyRemoveOldItems();

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
    } catch (e) {
      print("Error during processing tap: $e");
    }

    _isProcessingTap = false;
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
    _progressSubscription?.cancel();
    _qualitySubscription?.cancel();
    qualityValueNotifier.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    if (_arSessionManager != null) {
      if (_anchor != null) {
        _arAnchorManager!.removeAnchor(_anchor!);
      }
      if (_localObjectNode != null) {
        _arObjectManager!.removeNode(_localObjectNode!);
      }
      _anchor = null;
      _localObjectNode = null;
      _arSessionManager!.stopFetchingImages();
      _arSessionManager!.dispose();
    }
    super.dispose();
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
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

    // Anchor placement
    // _arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;

    _progressSubscription =
        _arSessionManager!.motionUpdatesStream.listen((progress) {
      setState(() {
        _progress = progress;
      });

      if (_progress >= 100) {
        setState(() {
          _currentStep+=2;
        });
        _arSessionManager!.startFetchingImages();
        _qualitySubscription = _arSessionManager!
            .depthQualityStream
            .listen((result) async {
          print("Received quality value: $result");
          qualityValueNotifier.value = result;
        }, onError: (error) {
          print("Error while receiving quality value: $error");
        });
        _arSessionManager!.stopMotionUpdates();
        _progressSubscription?.cancel();
        _progressSubscription = null;
      }
    });
  }

  Future<void> onCaptureImage(BuildContext context) async {
    _qualitySubscription?.cancel();
    stopLocationUpdates();
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
        final lines = result['lineJson'];
        if (mounted && imageResult != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => CaptureConfirm(
                      imageResult: imageResult!,
                      cameraImage: imgRGB,
                      // captureHeight: elevation!,
                      locations: _locations,
                      lineJson: lines,
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
          CustomDialog.show(context,
              dialogType: DialogType.singleButton,
              message:
                  '${e.cause}\nPlease re-capture to continue.',
              // cancelText: 'Re-capture',
              // confirmText: 'Manually Input',
              confirmText: 'Re-capture',
              onConfirmed: () {
                _currentStep = 2;
                _isRetrial = true;
                _locations.clear();
                startLocationUpdates();
                Navigator.of(context).pop();
              });
          //     onConfirmed: () async {
          //   ui.Image image = await ImageUtil.bytesToUiImage(imgRGB.bytes!);
          //
          //   if (mounted) {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => Scaffold(
          //           body: DraggableImagePainter(
          //             image: image,
          //             cameraImage: imgRGB,
          //           ),
          //         ),
          //       ),
          //     );
          //   }
          // }, onCanceled: () {
          //       _currentStep = 2;
          //       _isRetrial = true;
          // });
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
