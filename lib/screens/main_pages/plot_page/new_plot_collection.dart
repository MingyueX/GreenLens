import 'package:flutter/material.dart';

import '../../../base/widgets/gradient_bg.dart';
import 'widget/plot_collect_card.dart';

class AddPlotPage extends StatelessWidget {
  const AddPlotPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: GradientBg(
            child: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child:
                            Card(elevation: 1.0, child: PlotCollectCard()))))));
  }
}
