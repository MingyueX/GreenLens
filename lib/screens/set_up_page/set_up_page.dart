import 'package:flutter/material.dart';
import 'package:tree/base/widgets/plain_button.dart';
import 'package:tree/screens/plot_page/plot_collect_page.dart';

import '../../base/widgets/confirm_button.dart';
import '../../base/widgets/gradient_bg.dart';

class SetUpPage extends StatelessWidget {
  const SetUpPage({Key? key}) : super(key: key);

  static const double textSpacing = 8;
  static const double spacing = 20;

  static const String titleLine1 = "Set up your";
  static const String titleLine2 = "Plot & Tree Data";
  static const String bodyText1 =
      '''Record detailed information about your plots and the trees within them to contribute to a comprehensive understanding of the forest.''';
  static const String bodyText2 =
      '''Start the setup or choose to skip for now. You can always return to complete it later.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/set_up_page.png",
            fit: BoxFit.fitWidth,
          ),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: spacing),
                  Text(titleLine1,
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: textSpacing),
                  Text(titleLine2,
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: spacing),
                  Text(bodyText1, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: spacing),
                  Text(bodyText2, style: Theme.of(context).textTheme.bodySmall),
                ],
              )),
          const SizedBox(height: spacing),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ConfirmButton(
                buttonPrompt: "SET UP",
                padding: 25,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PlotCollectPage()));
                }),
          ),
          const SizedBox(height: textSpacing),
          const PlainButton(buttonPrompt: "SKIP FOR NOW"),
        ],
      )),
    );
  }
}
