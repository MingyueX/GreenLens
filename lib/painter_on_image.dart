import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tree/theme/colors.dart';

class DraggableImagePainter extends StatefulWidget {
  const DraggableImagePainter({Key? key, this.image, required this.cameraImage})
      : super(key: key);

  final CameraImage cameraImage;
  final ui.Image? image;

  @override
  State<DraggableImagePainter> createState() => _DraggableImagePainterState();
}

class _DraggableImagePainterState extends State<DraggableImagePainter> {
  Offset offset1 = Offset(0, 0);
  Offset offset2 = Offset(0, 0);
  Path path1 = Path();
  Path path2 = Path();
  // TODO: implement dragging if needed
  // bool _dragging = false;
  int _strokeDrawn = 0;
  GlobalKey repaintBoundaryKey = GlobalKey();

  bool _insidePath(double x, double y, Path path, Offset offset) {
    return path.getBounds().contains(Offset(x - offset.dx, y - offset.dy));
  }

  void _deleteStroke() {
    // Reset the path, offset, and stroke drawn flag
    setState(() {
      path1 = Path();
      path2 = Path();
      offset1 = Offset(0, 0);
      offset2 = Offset(0, 0);
      _strokeDrawn = 0;
    });
  }

  Future<void> _saveAsImage(double ratio) async {
    // Create a boundary with the key of the widget that contains the image and path
    RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;

    /*final image = await boundary.toImage(
      pixelRatio: 1 / ratio,
    );*/

    // paint the path with width 1px for saving
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(Offset(0, 0), Offset(boundary.size.width, boundary.size.height))
    );

    final painter = MultiplePathPainter(path1, path2, offset1, offset2, width: 1.0);

    painter.paint(canvas, boundary.size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      boundary.size.width.toInt(),
      boundary.size.height.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final rgbaBytes = byteData!.buffer.asUint8List();
    String base64String = base64Encode(rgbaBytes);

    /*final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsString(base64String);

    print(base64String);*/

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageDisplayScreen(imageBytes: rgbaBytes),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double imageWidth = widget.cameraImage.width?.toDouble() ?? 0;
    double imageHeight = widget.cameraImage.height?.toDouble() ?? 0;
    double screenHeight = MediaQuery.of(context).size.height;

    double ratio = screenHeight / imageHeight;

    double scaledWidth = imageWidth * ratio;
    double scaledHeight = imageHeight * ratio;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0)),
            child: Image.memory(widget.cameraImage.bytes!)),
        Container(
            width: scaledWidth,
            height: scaledHeight,
            child: GestureDetector(
              onPanStart: (details) {
                if (_strokeDrawn >= 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Only two strokes are allowed'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                } else if (_strokeDrawn == 0) {
                  double dx = details.localPosition.dx - offset1.dx;
                  double dy = details.localPosition.dy - offset1.dy;
                  path1.moveTo(dx, dy);
                } else if (_strokeDrawn == 1) {
                  double dx = details.localPosition.dx - offset2.dx;
                  double dy = details.localPosition.dy - offset2.dy;
                  path2.moveTo(dx, dy);
                }
              },
              onPanEnd: (details) {
                if (_strokeDrawn < 2) _strokeDrawn++;
              },
              onPanUpdate: (details) {
                if (_strokeDrawn == 0) {
                  setState(() {
                    double dx = details.localPosition.dx - offset1.dx;
                    double dy = details.localPosition.dy - offset1.dy;
                    path1.lineTo(dx, dy);
                  });
                }
                if (_strokeDrawn == 1) {
                  setState(() {
                    double dx = details.localPosition.dx - offset2.dx;
                    double dy = details.localPosition.dy - offset2.dy;
                    path2.lineTo(dx, dy);
                  });
                }
              },
              child: /*RepaintBoundary(
                key: repaintBoundaryKey,
                child: */
                RepaintBoundary(
                  key: repaintBoundaryKey,
                  child:
                  /*Container(
                    width: scaledWidth,
                    height: scaledHeight,
                    child: ClipRect(
                      child: CustomPaint(
                        painter: PathPainter(path, offset, width: 1.0),
                        child: Container(),
                      ),
                    ),
                  ),),*/
                  Container(
                  width: scaledWidth,
                  height: scaledHeight,
                  child: ClipRect(
                    child: CustomPaint(
                      painter: MultiplePathPainter(path1, path2, offset1, offset2),
                      child: Container(),
                    ),
                  ),
                ))
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
                    onPressed: _deleteStroke,
                    child: const Text('Re-paint'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_strokeDrawn < 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please draw 2 strokes before confirming'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      _saveAsImage(ratio);
                    },
                    child: const Text('Confirm'),
                  ),
                ])),
      ],
    );
  }
}

/*class PathPainter extends CustomPainter {
  PathPainter(this.path, this.offset, {this.width = 5.0});

  final Path path;
  final Offset offset;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path.shift(offset), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}*/

class MultiplePathPainter extends CustomPainter {
  MultiplePathPainter(this.path1, this.path2, this.offset1, this.offset2, {this.width = 5.0});

  final Path path1, path2;
  final Offset offset1, offset2;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen  // assuming you've defined this color somewhere
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path1.shift(offset1), paint);
    canvas.drawPath(path2.shift(offset2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ImageDisplayScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const ImageDisplayScreen({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0)),
            child: Image.memory(imageBytes)),
      ),
    );
  }
}
