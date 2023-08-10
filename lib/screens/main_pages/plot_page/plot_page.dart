import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tree/base/widgets/plain_button.dart';
import 'package:tree/screens/main_pages/plot_page/new_plot_collection.dart';
import 'package:tree/screens/main_pages/plot_page/plot_page_viewmodel.dart';
import 'package:tree/theme/themes.dart';

import '../../../base/widgets/gradient_bg.dart';
import '../../../model/models.dart';
import '../../../theme/colors.dart';

class PlotPage extends StatelessWidget {
  const PlotPage({Key? key}) : super(key: key);

  static const double padding = 17;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlotPageViewModel>();

    return GradientBg(child: SingleChildScrollView(child:
        BlocBuilder<PlotPageViewModel, PlotsState>(builder: (context, state) {
      if (state.plots.isEmpty) {
        return Center(
            child: PlainButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (context) => const AddPlotPage()));
                },
                buttonPrompt: "+ ADD PLOT"));
      } else {
        return Container(
            padding: const EdgeInsets.all(0),
            height: 580,
            child: ListView.separated(
              itemCount: state.plots.length,
              itemBuilder: (BuildContext context, int index) {
                return PlotItem(
                  plot: state.plots[index],
                  id: index + 1,
                  onDelete: (plot) => viewModel.removePlot(plot),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ));
      }
    })));
  }
}

class PlotItem extends StatelessWidget {
  const PlotItem(
      {Key? key, required this.plot, required this.id, required this.onDelete})
      : super(key: key);

  final int id;
  final Plot plot;

  final Function onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headlineLarge,
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Plot',
                            ),
                            TextSpan(
                                // TODO: check if it's safe to use plot.id here
                                text: "#$id",
                                style: Theme.of(context).textTheme.labelMedium)
                          ],
                        ),
                      ),
                      Text(DateFormat.yMd().format(plot.date)),
                    ]),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: List.generate(
                      50,
                      (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0
                                  ? Colors.transparent
                                  : AppColors.grey,
                              height: 1,
                            ),
                          )),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TwoSegRichText(
                          seg1: 'Cluster', seg2: '#${plot.clusterId}'),
                      TwoSegRichText(seg1: 'Group', seg2: '#${plot.groupId}'),
                      TwoSegRichText(seg1: 'Farm', seg2: '#${plot.farmId}')
                    ]),
                const SizedBox(
                  height: 5,
                ),
                if (plot.harvesting)
                  const TwoSegRichText(
                    seg1: "Harvesting",
                    seg2: " in progress",
                    leadingBold: true,
                  ),
                if (plot.thinning)
                  const TwoSegRichText(
                    seg1: "Thinning",
                    seg2: " in progress",
                    leadingBold: true,
                  ),
                const SizedBox(
                  height: 5,
                ),
                TwoSegRichText(
                    seg1: "Dominant Land Use: ", seg2: plot.dominantLandUse),
                const SizedBox(
                  height: 5,
                ),
                const PlainButton(buttonPrompt: "VIEW TREE INFO"),
                const SizedBox(
                  height: 5,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  GestureDetector(
                      onTap: () {
                        onDelete(plot);
                      },
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        color: AppColors.alertRed,
                      ))
                ]),
              ],
            )));
  }
}

class TwoSegRichText extends StatelessWidget {
  const TwoSegRichText(
      {Key? key,
      required this.seg1,
      required this.seg2,
      this.leadingBold = false})
      : super(key: key);

  final String seg1;
  final String seg2;
  final bool leadingBold;

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: <TextSpan>[
          TextSpan(
              text: seg1,
              style: leadingBold
                  ? Theme.of(context).textTheme.bodyMediumBold
                  : null),
          TextSpan(
              text: seg2,
              style: leadingBold
                  ? null
                  : Theme.of(context).textTheme.bodyMediumBold)
        ]));
  }
}
