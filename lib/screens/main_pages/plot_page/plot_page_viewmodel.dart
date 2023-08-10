import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/models.dart';
import '../../../services/storage/db_service.dart';

class PlotsState {
  final List<Plot> plots;

  PlotsState(this.plots);
}

class PlotPageViewModel extends Cubit<PlotsState> {
  PlotPageViewModel() : super(PlotsState([]));

  final dbService = DatabaseService();

  Future<void> addPlot(Plot plot) async {
    print("entered");
    await dbService.insertPlot(plot);
    List<Plot> updatedPlots = await dbService.searchPlotByFarmerId(plot.farmerId);
    for (Plot plot in updatedPlots) {
      print('${plot.farmerId} ${plot.id} ${plot.clusterId} ${plot.groupId}');
    }
    emit(PlotsState(updatedPlots));
  }

  Future<void> removePlot(Plot plot) async {
    print("a");
    for (Plot p in state.plots) {
      print('${p.farmerId} ${p.id} ${p.clusterId} ${p.groupId}');
    }
    print('${plot.farmerId} ${plot.id} ${plot.clusterId} ${plot.groupId}');
    await dbService.deletePlotById(plot.id!);
    print("b");
    emit(PlotsState([...state.plots]..remove(plot)));
  }
}