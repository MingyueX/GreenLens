import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:GreenLens/base/widgets/app_bar.dart';
import 'package:GreenLens/base/widgets/plain_button.dart';
import 'package:GreenLens/screens/main_pages/plot_page/new_plot_collection.dart';
import 'package:GreenLens/screens/main_pages/plot_page/plot_page_viewmodel.dart';
import 'package:GreenLens/screens/main_pages/tree_page/tree_page_viewmodel.dart';
import 'package:GreenLens/screens/page_navigation/page_nav_viewmodel.dart';
import 'package:GreenLens/theme/themes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../base/widgets/dialog.dart';
import '../../../model/models.dart';
import '../../../services/storage/db_service.dart';
import '../../../theme/colors.dart';
import '../../../utils/file_storage.dart';
import '../profile_page/farmer_provider.dart';

class PlotPage extends StatelessWidget {
  const PlotPage({Key? key}) : super(key: key);

  static const double padding = 17;

  String escapeForCsv(String? value) {
    if (value == null) return '';
    // Escape double quotes
    String escaped = value.replaceAll('"', '""');
    // Enclose in double quotes if it contains commas, newlines, or double quotes
    if (escaped.contains(',') || escaped.contains('\n') || escaped.contains('"')) {
      escaped = '"$escaped"';
    }
    return escaped;
  }

  Future<File?> generateAndSaveCSV(Farmer? currentUser) async {
    final dbService = DatabaseService();
    if (currentUser != null) {
      final List<PlotWithTrees> plots =
          await dbService.fetchPlotsWithTrees(currentUser.participantId);
      List<String> rows = [];

      // Define CSV header
      rows.add('''ParticipantID,ParticipantName,PlotID,PlotUID,Date,Harvesting,Thinning,DominantLandUse,TreeID,TreeUID,Latitude,Longitude,IsEucalyptus,Condition,ConditionDetail,ConditionStatusCode,CauseOfDeath,Age,Species,Diameter,LineJSON,IsTreeValid,IsPlotValid''');

      for (final plotWithTrees in plots) {
        for (final tree in plotWithTrees.trees) {
          // Create a row for each tree, including plot information
          rows.add('''${currentUser.participantId},${currentUser.name},${plotWithTrees.plot.id},${plotWithTrees.plot.uid ?? ''},${DateFormat('yyyy-MM-dd').format(plotWithTrees.plot.date)},${plotWithTrees.plot.harvesting},${plotWithTrees.plot.thinning},${plotWithTrees.plot.dominantLandUse},${tree.id},${tree.uid ?? ''},${tree.locationLatitude},${tree.locationLongitude},${tree.isEucalyptus},${tree.condition.name},${tree.conditionDetail?.detail ?? ''},${tree.conditionDetail?.statusCode ?? ''},${tree.causeOfDeath ?? ''},${tree.age ?? ''},${tree.species ?? ''},${tree.diameter ?? ''},${escapeForCsv(tree.lineJson)},${tree.isValid},${plotWithTrees.plot.isValid}''');
        }
      }

      String csvStr = rows.join('\n');

      final basePath = await FileStorage.getBasePath();
      String path =
          '$basePath/Participant#${currentUser == null ? "unknown" : "${currentUser.participantId}"}';
      // final now = DateTime.now();
      // String date = DateFormat('yyyy-MM-dd').format(now);
      // String time = DateFormat.Hms().format(now).replaceAll(':', '');
      final file = File('$path/plotAndTreeData.csv');
      await file.parent.create(recursive: true);
      await file.writeAsString(csvStr);
      return file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlotPageViewModel>();

    Farmer? currentUser;
    if (context.mounted) {
      currentUser = Provider.of<FarmerProvider>(context, listen: false).farmer;
    }

    return Scaffold(
        appBar: CustomAppBar(
          title: 'Plots',
          actions: {
            Icons.share: () async {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Wrap(
                      children: <Widget>[
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 15, bottom: 5),
                              child: Text(
                                'Export Data as CSV',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ListTile(
                          title: const Text('Save to Device'),
                          onTap: () async {
                            await generateAndSaveCSV(currentUser);
                            if (context.mounted) {
                              SnackBar snackBar = const SnackBar(
                                content: Text('File saved to device'),
                                duration: Duration(seconds: 1),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);

                              Navigator.pop(context);
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('Open with Other App'),
                          onTap: () async {
                            final file = await generateAndSaveCSV(currentUser);
                            if (file != null && await file.exists()) {
                              final files = <XFile>[];
                              files.add(XFile(file.path));
                              Share.shareXFiles(files);
                            } else {
                              print('Error: File does not exist.');
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('Cancel'),
                          onTap: () {
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            Icons.add: () {
              Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) => const AddPlotPage()));
            }
          },
        ),
        body: Container(
            color: AppColors.lightBackground,
            child: BlocBuilder<PlotPageViewModel, PlotsState>(
                builder: (context, state) {
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    height: 580,
                    child: ListView.separated(
                      itemCount: state.plots.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PlotItem(
                          plot: state.plots[index],
                          onDelete:
                                (plot) {
                              CustomDialog.show(context,
                                  message: "Delete this plot? All trees within the plot will be deleted as well.",
                                  dialogType: DialogType.doubleButton,
                                  onConfirmed: () async {
                                    await viewModel.removePlot(
                                        plot, currentUser?.participantId);
                                    if (context.mounted) {
                                      SnackBar snackBar = const SnackBar(
                                        content: Text('Plot Deleted'),
                                        duration: Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      Navigator.of(context).pop();
                                    }
                                  }
                              );
                            }
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 5);
                      },
                    ));
              }
            })));
  }
}

class PlotItem extends StatelessWidget {
  const PlotItem({Key? key, required this.plot, required this.onDelete})
      : super(key: key);

  // TODO: review after decide on plot id
  // final int id;
  final Plot plot;

  final Function onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                                text: "#${plot.id}",
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
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       TwoSegRichText(
                //           seg1: 'Cluster', seg2: '#${plot.clusterId}'),
                //       TwoSegRichText(seg1: 'Group', seg2: '#${plot.groupId}'),
                //       TwoSegRichText(seg1: 'Farm', seg2: '#${plot.farmId}')
                //     ]),
                if (plot.harvesting)
                  const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: TwoSegRichText(
                        seg1: "Harvesting",
                        seg2: " in progress",
                        leadingBold: true,
                      )),
                if (plot.thinning)
                  const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: TwoSegRichText(
                        seg1: "Thinning",
                        seg2: " in progress",
                        leadingBold: true,
                      )),
                const SizedBox(
                  height: 5,
                ),
                TwoSegRichText(
                    seg1: "Dominant Land Use: ", seg2: plot.dominantLandUse),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlainButton(
                        onPressed: () {
                          context
                              .read<TabbedPageViewModel>()
                              .switchToPage(MainPage.treePage, context);
                          context.read<TreePageViewModel>().setPlotId(plot.id!);
                        },
                        buttonPrompt: "VIEW TREE INFO"),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(builder: (context) => AddPlotPage(plot: plot,)));
                          },
                          child: const Icon(
                            Icons.edit,
                          )),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () {
                            onDelete(plot);
                            context.read<TreePageViewModel>().setPlotId(null);
                          },
                          child: const Icon(
                            Icons.delete_forever_outlined,
                            color: AppColors.alertRed,
                          ))
                    ]),
                  ],
                ),
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
