import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:tree/base/widgets/plain_button.dart';
import 'package:tree/image_capture_screen.dart';
import 'package:tree/theme/colors.dart';

import '../../../model/models.dart';

class TreeCollectCard extends StatefulWidget {
  const TreeCollectCard({Key? key}) : super(key: key);

  @override
  State<TreeCollectCard> createState() => _TreeCollectCardState();
}

class _TreeCollectCardState extends State<TreeCollectCard> {
  static const double spacing = 15;

  TreeAliveCondition? selectedCondition;

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<TreeAliveCondition>> conditionEntries =
        <DropdownMenuEntry<TreeAliveCondition>>[];
    for (final TreeAliveCondition condition in TreeAliveCondition.values) {
      conditionEntries.add(
        DropdownMenuEntry<TreeAliveCondition>(
            value: condition, label: condition.detail),
      );
    }

    return Form(
        child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Condition", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 5),
          ToggleSwitch(
            minWidth: 285,
            minHeight: 25,
            cornerRadius: 5,
            borderColor: const [AppColors.grey],
            inactiveBgColor: AppColors.baseWhite,
            inactiveFgColor: AppColors.grey,
            activeBgColor: const [AppColors.primaryGreen],
            dividerColor: AppColors.grey,
            activeBorders: [Border.all(color: AppColors.baseWhite, width: 2)],
            borderWidth: 1,
            labels: const ['ALIVE', 'NOT FOUND', 'NO LONGER EXIST'],
            customWidths: const [60, 90, 135],
            customTextStyles: const [
              TextStyle(fontSize: 12.0),
              TextStyle(fontSize: 12.0),
              TextStyle(fontSize: 12.0),
            ],
          ),
          SizedBox(height: 12),
          DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.grey)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.grey)),
                  contentPadding: EdgeInsets.only(left: 10)
              ),
              hint: Text("Select Condition Details"),
              menuMaxHeight: 250,
              focusColor: AppColors.primaryGreen,
              value: selectedCondition,
              borderRadius: BorderRadius.circular(5),
              isExpanded: true,
              isDense: false,
              items: TreeAliveCondition.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.detail,
                        ),
                      ))
                  .toList(),
              onChanged: (condition) {
                setState(() {
                  selectedCondition = condition;
                });
              }),

          /*DropdownMenu<TreeAliveCondition>(
            initialSelection: TreeAliveCondition.normal,
            label: const Text('Color'),
            dropdownMenuEntries: conditionEntries,
            onSelected: (TreeAliveCondition? condition) {
              setState(() {
                selectedCondition = condition;
              });
            },
            menuStyle: MenuStyle(
              shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
              minimumSize: MaterialStateProperty.all(Size(285, 25)),
              maximumSize: MaterialStateProperty.all(Size(285, 200)),
            ),
          ),*/

          const SizedBox(height: spacing),
          Text("Location", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: spacing),
          Text("Orientation",
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Diameter(m)",
                  style: Theme.of(context).textTheme.headlineMedium),
              PlainButton(
                  buttonPrompt: "CAPTURE➜",
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ImageCaptureScreen()));
                  })
            ],
          ),
          const SizedBox(height: spacing),
        ],
      ),
    ));
  }
}
