import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:GreenLens/screens/main_pages/tree_page/widget/tree_collect_card.dart';

import '../../base/widgets/confirm_button.dart';
import '../../base/widgets/gradient_bg.dart';
import '../../base/widgets/plain_button.dart';

/// deprecated page, used nowhere for now
class TreeWidget {
  bool isExpanded;
  TreeCollectCard treeCard;

  TreeWidget({this.isExpanded = true, required this.treeCard});
}

class TreeCollectPage extends StatefulWidget {
  const TreeCollectPage({Key? key, required this.plotId}) : super(key: key);

  final int plotId;

  @override
  State<TreeCollectPage> createState() => _TreeCollectPageState();
}

class _TreeCollectPageState extends State<TreeCollectPage> {
  final List<TreeWidget> plotList = [
    TreeWidget(treeCard: const TreeCollectCard())
  ];

  @override
  Widget build(BuildContext context) {
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
                            plotList.mapIndexed<ExpansionPanel>((index, tree) {
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
                                      text: "Tree",
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
                            body: tree.treeCard,
                            isExpanded: tree.isExpanded,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      PlainButton(
                          buttonPrompt: "+ ADD ANOTHER PLOT",
                          onPressed: () {
                            setState(() {
                              plotList.add(TreeWidget(
                                  treeCard: TreeCollectCard()));
                            });
                          }),
                      const SizedBox(height: 20),
                      const ConfirmButton(
                        buttonPrompt: "SAVE",
                      )
                    ])))));
  }
}
