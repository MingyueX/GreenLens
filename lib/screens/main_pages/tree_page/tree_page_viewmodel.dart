import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GreenLens/model/models.dart';

import '../../../services/storage/db_service.dart';
import '../../../utils/file_storage.dart';

class TreesState {

  final List<Tree> trees;
  int? plotId;
  int? treeId;

  TreesState(this.trees, {this.plotId, this.treeId});
}

class TreePageViewModel extends Cubit<TreesState> {
  TreePageViewModel() : super(TreesState([]));

  final dbService = DatabaseService();

  setPlotId(int? plotId) async {
    if (plotId == null) {
      emit(TreesState([], plotId: null));
      return;
    }
    List<Tree> updatedTrees = await dbService.searchValidTreeByPlotId(plotId);
    emit(TreesState(updatedTrees, plotId: plotId));
  }

  Future<int> addTree(Tree tree) async {
    final treeId = await dbService.insertTree(tree);
    List<Tree> updatedTrees = await dbService.searchValidTreeByPlotId(tree.plotId);
    emit(TreesState(updatedTrees, plotId: tree.plotId, treeId: treeId));
    return treeId;
  }

  Future<void> removeTree(Tree tree, int? farmerId) async {
    await dbService.markTreeAsInvalid(tree.id!);
    String basePath = await FileStorage.getBasePath();
    String path = '$basePath/Participant#${farmerId == null ? "unknown" : "$farmerId"}/Plot#${tree.plotId}/Tree#${tree.id}${tree.uid == null ? "" : "_${tree.uid}"}';
    await FileStorage.deleteDirectory(path);
    List<Tree> updatedTrees = await dbService.searchValidTreeByPlotId(tree.plotId);
    emit(TreesState(updatedTrees, plotId: tree.plotId));
  }

  Future<void> updateTree(Tree tree) async {
    await dbService.updateTree(tree);
    List<Tree> updatedTrees = await dbService.searchValidTreeByPlotId(tree.plotId);
    emit(TreesState(updatedTrees, plotId: tree.plotId));
  }
}