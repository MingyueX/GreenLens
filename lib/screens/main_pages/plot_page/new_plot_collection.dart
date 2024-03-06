import 'package:flutter/material.dart';

import '../../../base/widgets/gradient_bg.dart';
import '../../../model/models.dart';
import 'widget/plot_collect_card.dart';

class AddPlotPage extends StatelessWidget {
  const AddPlotPage({Key? key, this.plot}) : super(key: key);

  final Plot? plot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GradientBg(
            child: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child:
                            Card(elevation: 1.0, child: PlotCollectCard(plot: plot,)))))));
  }
}
