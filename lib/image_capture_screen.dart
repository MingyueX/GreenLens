import 'dart:async';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
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
import 'package:tree/capture_confirmation_screen.dart';
import 'package:tree/theme/colors.dart';
import 'package:vector_math/vector_math_64.dart';

import 'image_processor.dart';
import 'image_processor_interface.dart';

class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({Key? key}) : super(key: key);

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  double? elevation;
  Timer? elevationTimer;

  List<ARNode> _arNodes = [];
  List<ARAnchor> _anchors = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    startElevationTimer();
  }

  void startElevationTimer() {
    elevationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      if (_anchors.isNotEmpty) {
        double? newElevation = await getElevationFromAnchor(_anchors.last);
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
      body: Container(
        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    await onCaptureImage(context);
                  },
                  child: const Text("Capture"),
                )),
            Align(
                alignment: Alignment.topRight,
                child: Text(
                  "Elevation: ${elevation ?? 0.0}",
                  style: const TextStyle(
                    color: AppColors.baseBlack,
                    fontSize: 20,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      var newAnchor =
          ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await _arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor!) {
        _anchors.add(newAnchor);

        // TODO: Add note to anchor to indicate the point
        /*var newNode = ARNode(
           type: NodeType.,
           scale: Vector3(0.1, 0.1, 0.1),
           position: Vector3(0.0, 0.0, 0.0),
           rotation: Vector4(1.0, 0.0, 0.0, 0.0), uri: '');
        bool? didAddNodeToAnchor =
        await this.arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
        if (didAddNodeToAnchor!) {
          this.nodes.add(newNode);
        } else {
          this.arSessionManager!.onError("Adding Node to Anchor failed");
        }*/
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    elevationTimer?.cancel();
    _arSessionManager!.dispose();
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
        showFeaturePoints: false, showPlanes: false, showWorldOrigin: true);
    _arObjectManager!.onInitialize();

    _arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
  }

  Future<void> onCaptureImage(BuildContext context) async {
    print("entered function");
    print("entered function");
    CameraImage imgRGB = await _arSessionManager!.getCameraImage();
    print("got camera images");
    ARImage arImage = await _arSessionManager!.getDepthImage();

    print(imgRGB.width);

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
      imageResult = await imageProcessor.processImage(context, imageRaw);
    }

    if (mounted && imageResult != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CaptureConfirm(
              imageResult: imageResult!, cameraImage: imgRGB, arImage: arImage),
        ),
      );
    }
  }
}
