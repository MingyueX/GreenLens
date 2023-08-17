import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tree/base/widgets/confirm_button.dart';
import 'package:tree/base/widgets/plain_button.dart';
import 'package:tree/farmer_provider.dart';
import 'package:tree/screens/main_pages/plot_page/widget/plot_collect_card.dart';
import 'package:tree/screens/plot_list_page/collected_plot_list.dart';

import '../../base/widgets/gradient_bg.dart';

/// deprecated page, used nowhere for now
class PlotWidget {
  bool isExpanded;
  PlotCollectCard plotCard;

  PlotWidget({this.isExpanded = true, required this.plotCard});
}

class PlotCollectPage extends StatefulWidget {
  const PlotCollectPage({Key? key}) : super(key: key);

  @override
  State<PlotCollectPage> createState() => _PlotCollectPageState();
}

class _PlotCollectPageState extends State<PlotCollectPage> {
  final List<PlotWidget> plotList = [
    PlotWidget(plotCard: const PlotCollectCard())
  ];

  @override
  Widget build(BuildContext context) {
    final farmerID = Provider.of<FarmerProvider>(context).farmer?.participantId;

    return Scaffold(
        body: GradientBg(
            child: Padding(
                padding: const EdgeInsets.all(17),
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const SizedBox(height: 40),
                      ExpansionPanelList(
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            plotList[index].isExpanded = !isExpanded;
                          });
                        },
                        children:
                            plotList.mapIndexed<ExpansionPanel>((index, plot) {
                          return ExpansionPanel(
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return ListTile(
                                  title: RichText(
                                text: TextSpan(
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Plot',
                                    ),
                                    TextSpan(
                                        text: "#${index + 1}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium)
                                  ],
                                ),
                              ));
                            },
                            body: plot.plotCard,
                            isExpanded: plot.isExpanded,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      PlainButton(
                          buttonPrompt: "+ ADD ANOTHER PLOT",
                          onPressed: () {
                            setState(() {
                              plotList.add(PlotWidget(
                                  plotCard: const PlotCollectCard()));
                            });
                          }),
                      const SizedBox(height: 20),
                      ConfirmButton(
                          buttonPrompt: "CONTINUE",
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CollectedPlotList(
                                    plotIds: List<int>.generate(
                                        plotList.length, (i) => i + 1))));
                          })
                    ])))));
  }
}
