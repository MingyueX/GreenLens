import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:ar_flutter_plugin/models/camera_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:GreenLens/theme/colors.dart';

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

  /// for dragging, not used yet
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

  double _averageXCoordinateOfPath(Path path) {
    List<Offset> points = [];
    for (PathMetric metric in path.computeMetrics()) {
      for (double t = 0; t <= 1.0; t += 0.01) {
        points.add(metric.getTangentForOffset(metric.length * t)!.position);
      }
    }
    return points.map((e) => e.dx).reduce((a, b) => a + b) / points.length;
  }

  Future<Uint8List> _saveSingleStrokeAsImage(Path path, Offset offset, double ratio) async {
    // Create a boundary with the key of the widget that contains the image and path
    RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;

    // paint the path with width 1px for saving
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(
            Offset(0, 0), Offset(boundary.size.width, boundary.size.height))
    );

    final painter = PathPainter(
        path, offset, width: 1.0);

    painter.paint(canvas, boundary.size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      boundary.size.width.toInt(),
      boundary.size.height.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    return pngBytes;
  }

  Future<void> _saveAsImage(double ratio) async {
    Path leftPath, rightPath;
    Offset leftOffset, rightOffset;

    if (_averageXCoordinateOfPath(path1) < _averageXCoordinateOfPath(path2)) {
      leftPath = path1;
      rightPath = path2;
      leftOffset = offset1;
      rightOffset = offset2;
    } else {
      leftPath = path2;
      rightPath = path1;
      leftOffset = offset2;
      rightOffset = offset1;
    }

    final leftBytes = await _saveSingleStrokeAsImage(leftPath, leftOffset, ratio);
    final rightBytes = await _saveSingleStrokeAsImage(rightPath, rightOffset, ratio);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageDisplayScreen(imageBytesLeft: leftBytes, imageBytesRight: rightBytes,),
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
              child:
                RepaintBoundary(
                  key: repaintBoundaryKey,
                  child:
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

class PathPainter extends CustomPainter {
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
}

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

class ImageDisplayScreen extends StatefulWidget {
  final Uint8List imageBytesLeft;
  final Uint8List imageBytesRight;

  const ImageDisplayScreen({
    Key? key,
    required this.imageBytesLeft,
    required this.imageBytesRight,
  }) : super(key: key);

  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            _buildImage(widget.imageBytesLeft),
            _buildImage(widget.imageBytesRight),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPage == 0) {
            _pageController.animateToPage(1,
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          } else {
            _pageController.animateToPage(0,
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        },
        child: Icon(Icons.swap_horiz),
      ),
    );
  }

  Widget _buildImage(Uint8List imageBytes) {
    return Center(
    child:
      Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.0)),
      child: Image.memory(imageBytes),
    ));
  }
}

