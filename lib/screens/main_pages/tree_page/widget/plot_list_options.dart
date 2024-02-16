import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GreenLens/screens/main_pages/plot_page/plot_page_viewmodel.dart';
import 'package:GreenLens/screens/main_pages/tree_page/tree_page_viewmodel.dart';

class PlotListOptions extends StatelessWidget {
  const PlotListOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final plots = context.read<PlotPageViewModel>().state.plots;

    return Dialog(child:
        Container(
            constraints: const BoxConstraints(maxHeight: 400),
            padding: const EdgeInsets.all(10), child:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          Text("Plot List", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(plots.length > 0 ?
              "Choose any plot to view tree data"
              : "No plots yet",
              style: Theme.of(context).textTheme.bodySmall),
          ListView.separated(
            itemCount: plots.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Plot #${plots[index].id}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.read<TreePageViewModel>().setPlotId(plots[index].id);
                  Navigator.of(context).pop();
                },
              );
            },
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          )
        ])));
  }
}
