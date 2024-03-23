import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:GreenLens/image_processor/image_processor_interface.dart';
import 'package:GreenLens/image_processor/process_optimized.dart';
import 'package:GreenLens/utils/image_util.dart';
import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:GreenLens/theme/colors.dart';
import 'package:lottie/lottie.dart';
import 'package:vector_math/vector_math_64.dart' as math_vector;

import '../../base/widgets/line.dart';
import 'capture_confirmation_screen.dart';


class InteractiveLinesWidget extends StatefulWidget {
  final Map<String, dynamic> linesJson;
  final Function(String) onImgSaved;
  final ImageResult imageResult;
  final CameraImage cameraImage;
  final double focalLength;
  final ui.Image? image;

  InteractiveLinesWidget({
    required this.onImgSaved,
    required this.linesJson,
    required this.cameraImage,
    required this.focalLength,
    this.image, required this.imageResult,
  });

  @override
  _InteractiveLinesWidgetState createState() => _InteractiveLinesWidgetState();
}

class _InteractiveLinesWidgetState extends State<InteractiveLinesWidget> {
  List<Line> lines = [];
  double scale = 1.0;
  double previousScale = 1.0;
  Offset startFocalPoint = Offset.zero;
  Offset translation = Offset.zero;
  Offset previousTranslation = Offset.zero;
  double rotation = 0.0;
  double previousRotation = 0.0;
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    initializeLines();
  }

  void initializeLines() {
    double imageWidth = widget.cameraImage.width?.toDouble() ?? 0;
    double imageHeight = widget.cameraImage.height?.toDouble() ?? 0;
    double extensionLength = imageWidth * imageHeight;

    lines = parseLines(widget.linesJson).map((line) => line.extend(extensionLength)).toList();
  }

  void resetLines() {
    setState(() {
      initializeLines();
      scale = 1.0;
      translation = Offset.zero;
      rotation = 0.0;
    });
  }

  List<double> confirmLines() {
    // Find line by comparing x coordinates
    Line leftLine = lines[0].start.dx < lines[1].start.dx ? lines[0] : lines[1];
    Line rightLine = leftLine == lines[0] ? lines[1] : lines[0];

    //Find topmost point of the left line
    Offset topPointLeft = leftLine.start.dy < leftLine.end.dy ? leftLine.start : leftLine.end;
    Offset bottomPointLeft = leftLine.start.dy > leftLine.end.dy ? leftLine.start : leftLine.end;

    //Find topmost point of the right line
    Offset topPointRight = rightLine.start.dy < rightLine.end.dy ? rightLine.start : rightLine.end;
    Offset bottomPointRight = rightLine.start.dy > rightLine.end.dy ? rightLine.start : rightLine.end;

    final mLeft = (topPointLeft.dx - bottomPointLeft.dx) / (topPointLeft.dy - bottomPointLeft.dy);
    final mRight = (topPointRight.dx - bottomPointRight.dx) / (topPointRight.dy - bottomPointRight.dy);
    final nLeft = topPointLeft.dx - mLeft * topPointLeft.dy;
    final nRight = topPointRight.dx - mRight * topPointRight.dy;

    return [mLeft, nLeft, mRight, nRight];
  }

  String getNewLineJson() {
    // Find line by comparing x coordinates
    Line leftLine = lines[0].start.dx < lines[1].start.dx ? lines[0] : lines[1];
    Line rightLine = leftLine == lines[0] ? lines[1] : lines[0];

    //Find topmost point of the left line
    Offset topPointLeft = leftLine.start.dy < leftLine.end.dy ? leftLine.start : leftLine.end;
    Offset bottomPointLeft = leftLine.start.dy > leftLine.end.dy ? leftLine.start : leftLine.end;

    // Find topmost point of the right line
    Offset topPointRight = rightLine.start.dy < rightLine.end.dy ? rightLine.start : rightLine.end;
    Offset bottomPointRight = rightLine.start.dy > rightLine.end.dy ? rightLine.start : rightLine.end;

    return '''
    {
      "left_line": {
        "top_yx": [${topPointLeft.dx}, ${topPointLeft.dy}],
        "bottom_yx": [${bottomPointLeft.dx}, ${bottomPointLeft.dy}]
      },
      "right_line": {
        "top_yx": [${topPointRight.dx}, ${topPointRight.dy}],
        "bottom_yx": [${bottomPointRight.dx}, ${bottomPointRight.dy}]
      }
    }
    ''';
  }

  List<Line> parseLines(Map<String, dynamic> json) {
    return [
      Line.fromJson(json['left_line']),
      Line.fromJson(json['right_line']),
    ];
  }

  Matrix4 lineCenteredRotationMatrix(Line line, double scale, Offset translation, double rotation) {
    Matrix4 matrix = Matrix4.identity();

    matrix.scale(scale, scale, 1.0);
    matrix.translate(translation.dx, translation.dy, 0);
    matrix.rotateZ(rotation);

    return matrix;
  }

  // Offset transformPoint(Matrix4 matrix, Offset point) {
  //   math_vector.Vector3 vector = math_vector.Vector3(point.dx, point.dy, 0);
  //   vector = matrix.transform3(vector);
  //   return Offset(vector.x, vector.y);
  // }
  //
  // List<Line> transformLines(List<Line> originalLines, double scale, Offset translation, double rotation, Offset center) {
  //   return originalLines.map((line) {
  //     final transformMatrix = lineCenteredRotationMatrix(line, scale, translation, rotation);
  //     return Line(
  //       transformPoint(transformMatrix, line.start),
  //       transformPoint(transformMatrix, line.end),
  //     );
  //   }).toList();
  // }
  Offset transformPoint(Offset point, double scale, Offset translation, double rotation, Offset center) {
    // Translate point to origin based on center
    Offset translatedToOrigin = point - center;

    // Scale
    Offset scaledPoint = Offset(translatedToOrigin.dx * scale, translatedToOrigin.dy * scale);

    // Rotate
    double sinR = sin(rotation);
    double cosR = cos(rotation);
    Offset rotatedPoint = Offset(
      scaledPoint.dx * cosR - scaledPoint.dy * sinR,
      scaledPoint.dx * sinR + scaledPoint.dy * cosR,
    );

    // Translate back from origin and apply translation
    Offset finalPoint = rotatedPoint + center + translation;

    return finalPoint;
  }

  List<Line> transformLines(List<Line> originalLines, double scale, Offset translation, double rotation, Offset center) {
    return originalLines.map((line) {
      return Line(
        transformPoint(line.start, scale, translation, rotation, center),
        transformPoint(line.end, scale, translation, rotation, center),
      );
    }).toList();
  }


  Future<Image> drawLinesOnImage(CameraImage cameraImage, List<Line> lines) async {

    final baseImage = widget.image!;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final screenH = MediaQuery.of(context).size.height;
    final scaling = screenH / baseImage.height;

    // Draw the base image onto the canvas
    paintImage(canvas: canvas, image: baseImage, rect: Rect.fromLTWH(0, 0, baseImage.width.toDouble(), baseImage.height.toDouble()));

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0;

    for (var line in lines) {
      canvas.drawLine(line.start / scaling, line.end / scaling, paint);
    }

    final ui.Picture picture = recorder.endRecording();

    final ui.Image finalImage = await picture.toImage(baseImage.width, baseImage.height);
    ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    return Image.memory(pngBytes);
  }


  @override
  Widget build(BuildContext context) {
    double imageWidth = widget.image!.width.toDouble() ?? 0;
    double imageHeight = widget.image!.height.toDouble() ?? 0;
    double screenHeight = MediaQuery.of(context).size.height;

    double ratio = screenHeight / imageHeight;


    double scaledWidth = imageWidth * ratio;
    double scaledHeight = imageHeight * ratio;

    return Stack(
        alignment: Alignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0)),
              child: Image.memory(widget.cameraImage.bytes!)),
          Container(
              alignment: Alignment.center,
              width: scaledWidth,
              height: scaledHeight,
              child: GestureDetector(
                onScaleStart: (ScaleStartDetails details) {
                  startFocalPoint = details.focalPoint;
                  previousScale = scale;
                  previousTranslation = translation;
                  previousRotation = rotation;
                },
                onScaleUpdate: (ScaleUpdateDetails details) {
                  setState(() {
                    scale = (previousScale * details.scale).clamp(0.5, 15);
                    translation = previousTranslation + (details.focalPoint - startFocalPoint);
                    rotation = previousRotation + details.rotation;
                  });
                },
                onScaleEnd: (ScaleEndDetails details) {
                  previousScale = scale;
                  previousTranslation = translation;
                  previousRotation = rotation;
                },
                child: Transform(
                  alignment: FractionalOffset.center,
                  transform: Matrix4.identity()
                    ..scale(scale, scale, 1.0)
                    ..rotateZ(rotation)
                    ..translate(translation.dx, translation.dy),
                  child: CustomPaint(
                    painter: LinesPainter(lines: lines, scale: scale),
                    child: Container(),
                  ),
                ),
              )),
          Container(
            height: double.infinity,
            width: double.infinity,
            padding: const EdgeInsets.only(right: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      resetLines();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Offset center = Offset(scaledWidth / 2, scaledHeight / 2);
                      // Offset center = Offset(imageWidth / 2, imageHeight / 2);

                      lines = transformLines(lines, scale, translation, rotation, center);

                      final mns = confirmLines();
                      OptimizedProcessor processor = OptimizedProcessor();
                      final result = await processor.processImage(context, widget.imageResult.depthImage, widget.focalLength, mns);
                      final imageResult = widget.imageResult;
                      imageResult.diameter = result;
                      final newLineJson = getNewLineJson();
                      imageResult.lineJson = newLineJson;
                      // final image = await drawLinesOnImage(widget.cameraImage, lines);
                      // imageResult.displayImage = image;
                      if (mounted && imageResult != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => CaptureConfirm(
                                onImgSaved: widget.onImgSaved,
                                imageResult: imageResult!,
                                cameraImage: widget.cameraImage,
                                // captureHeight: elevation!,
                                locations: [],
                                focalLength: widget.focalLength,
                                lineJson: newLineJson,
                                diameter: result,
                              )),);}
                    },
                    child: const Text('Confirm'),
                  ),
                ])),
          _showAnimation ?
          // add a gray overlay to the screen when showing animation
          Center(
              child:
              Container(
                color: Colors.white.withOpacity(0.7),
                padding: EdgeInsets.all(20),
                height: double.infinity,
                width: double.infinity,
                child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform(
                        alignment: FractionalOffset.center,
                        // rotate 90 degrees
                        transform: Matrix4.identity()
                          ..rotateZ(60 * 3.1415927 / 180),
                        child:
                      Lottie.asset('assets/doublefinger.json', width: 300,),
                      ),
                      Text('Use two fingers to zoom,', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.baseBlack),),
                      Text('drag or rotate the lines.', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.baseBlack),),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showAnimation = false;
                          });
                        },
                        child: const Text('OK'),
                      )
                    ],
                  ),
            ),
          ) :
          Container()
        ]);
  }
}

