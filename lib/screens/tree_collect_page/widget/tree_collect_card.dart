import 'package:flutter/material.dart';
import 'package:tree/base/widgets/plain_button.dart';
import 'package:tree/image_capture_screen.dart';

class TreeCollectCard extends StatefulWidget {
  const TreeCollectCard({Key? key}) : super(key: key);

  @override
  State<TreeCollectCard> createState() => _TreeCollectCardState();
}

class _TreeCollectCardState extends State<TreeCollectCard> {
  static const double spacing = 15;

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Condition", style: Theme.of(context).textTheme.headlineMedium),
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
