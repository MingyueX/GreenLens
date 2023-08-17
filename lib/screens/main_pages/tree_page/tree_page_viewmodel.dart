import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tree/model/models.dart';

import '../../../services/storage/db_service.dart';

class TreesState {

  final List<Tree> trees;
  int? plotId;

  TreesState(this.trees, {this.plotId});
}

class TreePageViewModel extends Cubit<TreesState> {
  TreePageViewModel() : super(TreesState([]));

  final dbService = DatabaseService();

  setPlotId(int? plotId) async {
    if (plotId == null) {
      emit(TreesState([], plotId: null));
      return;
    }
    List<Tree> updatedTrees = await dbService.searchTreeByPlotId(plotId);
    emit(TreesState(updatedTrees, plotId: plotId));
  }

  Future<void> addTree(Tree tree) async {
    await dbService.insertTree(tree);
    List<Tree> updatedTrees = await dbService.searchTreeByPlotId(tree.plotId);
    emit(TreesState(updatedTrees, plotId: tree.plotId));
  }

  Future<void> removeTree(Tree tree) async {
    await dbService.deleteTreeById(tree.id!);
    emit(TreesState([...state.trees]..remove(tree), plotId: tree.plotId));
  }
}