import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class PositionVerifier extends StatelessWidget {
  const PositionVerifier({Key? key, required this.inGoodRange, this.accelerometerValues, required this.qualityValue}) : super(key: key);

  final double qualityValue;
  final bool inGoodRange;
  final List<double>? accelerometerValues;

  static const rangeRadius = 60.0;
  static const indicatorRadius = 30.0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

    Color boxColor = qualityValue < 0.5
        ? AppColors.lightRed
        : qualityValue >= 0.75 ? AppColors
        .lightGreen : AppColors
        .lightBlue;

    return Stack(children: [
      /// area that shows the range of the accepted pose && used to apply HSV algo
      Positioned(left: width / 2 - rangeRadius / 2,
          top: height / 2 - rangeRadius / 2,
          child: Container(
            width: rangeRadius,
            height: rangeRadius,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              gradient: RadialGradient(
                colors: [
                  boxColor.withOpacity(0.3),
                  boxColor.withOpacity(0.5),
                  boxColor.withOpacity(0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
                radius: 1.0,
                focal: const Alignment(0.1,
                    0.1),
              ),
              border: Border.all(
                color: boxColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: boxColor.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          )
      ),
      Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.only(top: 40),
            child: Text(
                qualityValue.toStringAsFixed(2),
                style: Theme
                    .of(context)
                    .textTheme
                    .labelLarge!.copyWith(color: boxColor)
            ),
          )),
      if (accelerometerValues != null)
        /// pose indicator
        Positioned(
          left: width / 2 + accelerometerValues![1] * 20 - indicatorRadius / 2,
          top: height / 2 - accelerometerValues![2] * 20 - indicatorRadius / 2,
          child: Container(
            width: indicatorRadius,
            height: indicatorRadius,
            decoration: BoxDecoration(
              color: inGoodRange ? AppColors.primaryGreen : AppColors.alertRed,
              shape: BoxShape.circle,
            ),
          ),
        ),
      if (!inGoodRange)
        /// message when not in good pose
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.baseBlack.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                  "Please hold your device perpendicular to the ground",
                  style: Theme
                      .of(context)
                      .textTheme
                      .labelLarge
              ),
            ))
    ],);
  }
}
