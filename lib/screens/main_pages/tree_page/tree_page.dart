import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GreenLens/base/widgets/app_bar.dart';
import 'package:GreenLens/screens/main_pages/tree_page/new_tree_collection.dart';
import 'package:GreenLens/screens/main_pages/tree_page/tree_page_viewmodel.dart';
import 'package:GreenLens/screens/main_pages/tree_page/widget/plot_list_options.dart';
import 'package:GreenLens/theme/themes.dart';

import '../../../base/custom_route.dart';
import '../../../base/widgets/plain_button.dart';
import '../../../model/models.dart';
import '../../../theme/colors.dart';
import '../../page_navigation/page_nav_viewmodel.dart';
import '../plot_page/new_plot_collection.dart';
import '../plot_page/plot_page.dart';
import '../plot_page/plot_page_viewmodel.dart';

class TreePage extends StatelessWidget {
  const TreePage({Key? key}) : super(key: key);

  static const double padding = 17;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TreePageViewModel>();
    final plots = context.watch<PlotPageViewModel>().state.plots;

    int? currentPlot = viewModel.state.plotId;

    return Scaffold(
        appBar: CustomAppBar(
          title:
              currentPlot == null ? 'No plot selected' : 'Trees - Plot#$currentPlot',
          actions: {
            Icons.list: () {
              Navigator.push(context,
                  CustomRoute(builder: (_) => const PlotListOptions()));
            },
            Icons.add: () {
              if (plots.isEmpty) {
                SnackBar snackBar = const SnackBar(
                  content: Text('Please add a plot first'),
                  duration: Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else if (currentPlot == null) {
                // TODO: display available plots
                SnackBar snackBar = const SnackBar(
                  content: Text('Please select a plot first'),
                  duration: Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => const AddTreePage()));
              }
            },
          },
        ),
        body: Container(
            color: AppColors.lightBackground,
            child: BlocBuilder<TreePageViewModel, TreesState>(
                builder: (context, state) {
              if (plots.isEmpty) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text("No plot yet",
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 10),
                      Text("Please add a plot first",
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 10),
                      PlainButton(
                          onPressed: () {
                            context
                                .read<TabbedPageViewModel>()
                                .switchToPage(MainPage.plotPage, context);
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                    builder: (context) => const AddPlotPage()));
                          },
                          buttonPrompt: "+ ADD PLOT")
                    ]));
              } else if (state.plotId == null) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text("No plot selected yet",
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 10),
                      Text("Please select a plot first",
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 10),
                      PlainButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                CustomRoute(
                                    builder: (_) => const PlotListOptions()));
                          },
                          buttonPrompt: "SELECT PLOT")
                    ]));
              } else if (state.trees.isEmpty) {
                return Center(
                    child: PlainButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (context) => const AddTreePage()));
                        },
                        buttonPrompt: "+ ADD TREE"));
              } else {
                return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    height: 580,
                    child: ListView.separated(
                      itemCount: state.trees.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TreeItem(
                          tree: state.trees[index],
                          onDelete: (tree) => viewModel.removeTree(tree),
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

class TreeItem extends StatelessWidget {
  const TreeItem(
      {Key? key, required this.tree, required this.onDelete})
      : super(key: key);

  final Tree tree;

  final Function onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                                  text: 'Tree',
                                ),
                                TextSpan(
                                    text: "#${tree.id}",
                                    style:
                                        Theme.of(context).textTheme.labelMedium)
                              ],
                            ),
                          ),
                          Text(tree.condition.name,
                              style: Theme.of(context).textTheme.dateLabel),
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
                    const TwoSegRichText(
                      seg1: "Eucalyptus",
                      seg2: "",
                      leadingBold: true,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TwoSegRichText(
                        seg1: "Locations: ",
                        seg2:
                            '(${tree.locationLatitude}, ${tree.locationLongitude})'),
                    const SizedBox(
                      height: 5,
                    ),
                    TwoSegRichText(
                        seg1: "Species ID: ", seg2: tree.speciesId.toString()),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Latest Record",
                      style: Theme.of(context).textTheme.bodyMediumBold,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(tree.conditionDetail?.detail ?? "No condition detail",
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(
                      height: 5,
                    ),
                    TwoSegRichText(
                        seg1: "Diameter (m): ",
                        seg2:
                            tree.diameter?.toStringAsFixed(2) ?? "No diameter"),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.edit,
                          )),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () {
                            onDelete(tree);
                          },
                          child: const Icon(
                            Icons.delete_forever_outlined,
                            color: AppColors.alertRed,
                          ))
                    ]),
                  ],
                ))));
  }
}
