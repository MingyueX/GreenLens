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
  Offset offset = Offset(0, 0);
  Path path = Path();
  bool _dragging = false;
  bool _strokeDrawn = false;
  GlobalKey repaintBoundaryKey = GlobalKey();

  bool _insidePath(double x, double y) {
    return path.getBounds().contains(Offset(x - offset.dx, y - offset.dy));
  }

  void _deleteStroke() {
    // Reset the path, offset, and stroke drawn flag
    setState(() {
      path = Path();
      offset = Offset(0, 0);
      _strokeDrawn = false;
    });
  }

  Future<void> _saveAsImage(double ratio) async {
    // Create a boundary with the key of the widget that contains the image and path
    RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(
      pixelRatio: 1 / ratio,
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
                if (_strokeDrawn) {
                  _dragging = _insidePath(
                    details.localPosition.dx,
                    details.localPosition.dy,
                  );
                } else {
                  path.moveTo(details.localPosition.dx - offset.dx,
                      details.localPosition.dy - offset.dy);
                }
              },
              onPanEnd: (details) {
                _dragging = false;
                if (!_strokeDrawn) _strokeDrawn = true;
              },
              onPanUpdate: (details) {
                if (_dragging) {
                  setState(() {
                    offset += details.delta;
                  });
                } else if (!_strokeDrawn) {
                  setState(() {
                    path.lineTo(details.localPosition.dx - offset.dx,
                        details.localPosition.dy - offset.dy);
                  });
                }
              },
              child: RepaintBoundary(
                key: repaintBoundaryKey,
                child: Container(
                  width: scaledWidth,
                  height: scaledHeight,
                  child: ClipRect(
                    child: CustomPaint(
                      painter: PathPainter(path, offset),
                      child: Container(),
                    ),
                  ),
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
                    onPressed: _deleteStroke,
                    child: const Text('Re-paint'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!_strokeDrawn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please draw a stroke before confirming'),
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

class PathPainter extends CustomPainter {
  PathPainter(this.path, this.offset);

  final Path path;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path.shift(offset), paint);
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
