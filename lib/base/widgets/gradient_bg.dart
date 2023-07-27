import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class GradientBg extends StatelessWidget {
  final double padding;
  final Widget? child;
  final List<Color>? colors;

  const GradientBg({super.key, this.padding = 0, this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: colors ??
                [
                  AppColors.gradientBgTop,
                  AppColors.gradientBgBottom,
                ],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: child);
  }
}
