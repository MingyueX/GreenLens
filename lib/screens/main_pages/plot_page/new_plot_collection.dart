import 'package:flutter/material.dart';

import '../../../base/widgets/gradient_bg.dart';
import '../../plot_page/widget/plot_collect_card.dart';

class AddPlotPage extends StatelessWidget {
  const AddPlotPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: GradientBg(
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 60,
                    ),
                    child: Card(elevation: 1.0, child: PlotCollectCard())))));
  }
}
