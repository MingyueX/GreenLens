import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class ToastLikeMsg extends StatelessWidget {
  const ToastLikeMsg(
      {Key? key, required this.msg, this.backgroundColor, this.textStyle})
      : super(key: key);

  final Color? backgroundColor;
  final String msg;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.baseBlack.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child:
          Text(msg, style: textStyle ?? Theme.of(context).textTheme.labelLarge),
    );
  }
}
