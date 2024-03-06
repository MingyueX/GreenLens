import 'package:GreenLens/utils/file_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/models.dart';
import '../../../services/storage/db_service.dart';
import '../../../utils/file_storage.dart';

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
    List<Plot> updatedPlots = await dbService.searchValidPlotByFarmerId(farmerId);
    emit(PlotsState(updatedPlots));
  }

  Future<void> addPlot(Plot plot) async {
    await dbService.insertPlot(plot);
    List<Plot> updatedPlots = await dbService.searchValidPlotByFarmerId(plot.farmerId);
    emit(PlotsState(updatedPlots));
  }

  Future<void> removePlot(Plot plot, int? farmerId) async {
    await dbService.markPlotAsInvalid(plot.id!);
    String basePath = await FileStorage.getBasePath();
    String path = '$basePath/Participant#${farmerId == null ? "unknown" : "$farmerId"}/Plot#${plot.id!}';
    await FileStorage.deleteDirectory(path);
    List<Plot> updatedPlots = await dbService.searchValidPlotByFarmerId(plot.farmerId);
    emit(PlotsState(updatedPlots));
  }

  Future<void> updatePlot(Plot plot) async {
    await dbService.updatePlot(plot);
    List<Plot> updatedPlots = await dbService.searchValidPlotByFarmerId(plot.farmerId);
    emit(PlotsState(updatedPlots));
  }
}