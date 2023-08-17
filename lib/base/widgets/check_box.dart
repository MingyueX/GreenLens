import 'package:flutter/material.dart';

class CheckBoxWithText extends StatelessWidget {
  const CheckBoxWithText({Key? key, required this.onChange, required this.currentValue}) : super(key: key);

  final bool currentValue;
  final Function onChange;

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3))),
            fillColor: currentValue
                ? MaterialStateProperty.all(
                Theme.of(context).colorScheme.primary)
                : null,
            value: currentValue,
            onChanged: (bool? value) {
              onChange(value);
            }),
        Text("YES", style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}
