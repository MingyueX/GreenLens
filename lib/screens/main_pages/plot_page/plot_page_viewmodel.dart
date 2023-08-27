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

  setFarmer(int? farmerId) async {
    if (farmerId == null) {
      emit(PlotsState([]));
      return;
    }
    List<Plot> updatedPlots = await dbService.searchPlotByFarmerId(farmerId);
    emit(PlotsState(updatedPlots));
  }

  Future<void> addPlot(Plot plot) async {
    await dbService.insertPlot(plot);
    List<Plot> updatedPlots = await dbService.searchPlotByFarmerId(plot.farmerId);
    for (Plot plot in updatedPlots) {
      print('${plot.farmerId} ${plot.id} ${plot.clusterId} ${plot.groupId}');
    }
    emit(PlotsState(updatedPlots));
  }

  Future<void> removePlot(Plot plot) async {
    await dbService.deletePlotById(plot.id!);
    emit(PlotsState([...state.plots]..remove(plot)));
  }
}