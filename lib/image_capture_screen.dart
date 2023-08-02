import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_image.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tree/capture_confirmation_screen.dart';

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

  List<ARNode> _arNodes = [];
  List<ARAnchor> _anchors = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
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
                child:
                ElevatedButton(
                  onPressed: () async {
                    await onCaptureImage(context);
                  },
                  child: const Text("Capture"),
                )
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
    _arSessionManager!.dispose();
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
        showWorldOrigin: true);
    _arObjectManager!.onInitialize();
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
      imageResult = await imageProcessor.processImage(
          context, imageRaw);
    }

    if (mounted && imageResult != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CaptureConfirm(imageResult: imageResult!, cameraImage: imgRGB, arImage: arImage),
        ),
      );
    }
  }
}
