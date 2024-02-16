import 'package:flutter/material.dart';
import 'package:GreenLens/theme/themes.dart';

class PlainButton extends StatelessWidget {
  const PlainButton({Key? key, required this.buttonPrompt, this.onPressed})
      : super(key: key);

  final String buttonPrompt;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed == null ? () {} : () => onPressed!(),
        child: Text(
          buttonPrompt,
          style: Theme.of(context).textTheme.plainButton,
        ));
  }
}
