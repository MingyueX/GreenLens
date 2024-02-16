import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:GreenLens/theme/themes.dart';

class CurrentDate extends StatelessWidget {
  const CurrentDate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy/MM/dd');
    String formattedDate = formatter.format(now);

    return Text(formattedDate, style: Theme.of(context).textTheme.dateLabel);
  }
}
