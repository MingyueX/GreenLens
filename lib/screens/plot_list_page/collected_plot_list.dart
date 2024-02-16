import 'package:flutter/material.dart';
import 'package:GreenLens/screens/tree_collect_page/tree_collect_page.dart';

import '../../base/widgets/confirm_button.dart';
import '../../base/widgets/gradient_bg.dart';

/// deprecated page, used nowhere for now
class CollectedPlotList extends StatelessWidget {
  const CollectedPlotList({Key? key, required this.plotIds}) : super(key: key);

  final List<int> plotIds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GradientBg(
            child: Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text("Plot List",
                          style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 8),
                      Text("Choose any plot to add tree data",
                          style: Theme.of(context).textTheme.bodySmall),
                      ListView.separated(
                        itemCount: plotIds.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text("Plot #${plotIds[index]}"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TreeCollectPage(plotId: plotIds[index])));
                            },
                          );
                        },
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                      ),
                      const SizedBox(height: 20),
                      const ConfirmButton(
                        buttonPrompt: "FINISH",
                      )
                    ]))));
  }
}
