import 'dart:ui' as ui;
import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:flutter/material.dart';

class DraggableImagePainter extends StatefulWidget {
  const DraggableImagePainter({Key? key, required this.cameraImage}) : super(key: key);

  final CameraImage cameraImage;

  @override
  State<DraggableImagePainter> createState() => _DraggableImagePainterState();
}

class _DraggableImagePainterState extends State<DraggableImagePainter> {
  Offset offset = Offset(0, 0);
  Path path = Path();
  bool _dragging = false;
  bool _strokeDrawn = false;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    // Decode the image from the CameraImage bytes
    ui.decodeImageFromPixels(
      widget.cameraImage.bytes!,
      widget.cameraImage.width!,
      widget.cameraImage.height!,
      ui.PixelFormat.rgba8888,
          (image) {
        setState(() {
          _image = image;
        });
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onPanStart: (details) {
              if (_strokeDrawn) {
                _dragging = _insidePath(
                  details.globalPosition.dx,
                  details.globalPosition.dy,
                );
              } else {
                path.moveTo(
                    details.globalPosition.dx - offset.dx,
                    details.globalPosition.dy - offset.dy);
              }
            },
            onPanEnd: (details) {
              _dragging = false;
              if (!_strokeDrawn) _strokeDrawn = true; // Mark stroke as drawn
            },
            onPanUpdate: (details) {
              if (_dragging) {
                setState(() {
                  offset += details.delta;
                });
              } else if (!_strokeDrawn) {
                setState(() {
                  path.lineTo(
                      details.globalPosition.dx - offset.dx,
                      details.globalPosition.dy - offset.dy);
                });
              }
            },
            child: Container(
              color: Colors.white,
              child: CustomPaint(
                painter: PathPainter(path, offset, _image),
                child: Container(),
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _deleteStroke,
          child: Text('Delete Stroke'),
        ), // Button to delete the stroke
      ],
    );
  }
}

class PathPainter extends CustomPainter {
  PathPainter(this.path, this.offset, this.image);
  final Path path;
  final Offset offset;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImage(image!, Offset.zero, Paint());
    }

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path.shift(offset), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}