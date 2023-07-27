import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  const ConfirmButton(
      {Key? key, required this.buttonPrompt, this.onPressed, this.padding})
      : super(key: key);

  final String buttonPrompt;
  final Function? onPressed;
  final double? padding;

  static const double buttonHeight = 40.0;
  static const double buttonBorderRadius = 5.0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(
              Theme.of(context).colorScheme.primary)),
      onPressed: onPressed == null ? () {} : () => onPressed!(),
      child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(buttonBorderRadius)),
          ),
          height: buttonHeight,
          alignment: Alignment.center,
          child: Text(
            buttonPrompt,
            style: Theme.of(context).textTheme.labelLarge,
          )),
    );
  }
}
