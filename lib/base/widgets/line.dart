import 'dart:math';

import 'package:flutter/material.dart';

class Line {
  Offset start;
  Offset end;

  Line(this.start, this.end);

  factory Line.fromJson(Map<String, dynamic> json) {
    return Line(
      Offset(json['top_yx'][0].toDouble(), json['top_yx'][1].toDouble()),
      Offset(json['bottom_yx'][0].toDouble(), json['bottom_yx'][1].toDouble()),
    );
  }

  Line scale(double scaleFactor) {
    return Line(
      Offset(start.dx * scaleFactor, start.dy * scaleFactor),
      Offset(end.dx * scaleFactor, end.dy * scaleFactor),
    );
  }

  Line extend(double length) {
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double magnitude = sqrt(dx * dx + dy * dy);

    dx /= magnitude;
    dy /= magnitude;

    Offset newStart = Offset(start.dx - dx * length, start.dy - dy * length);
    Offset newEnd = Offset(end.dx + dx * length, end.dy + dy * length);

    return Line(newStart, newEnd);
  }
}


