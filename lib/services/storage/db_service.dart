import 'package:GreenLens/services/storage/database.dart';

import '../../model/models.dart';

class DatabaseService {
  final Database db = Database.instance;

  Future<void> insertFarmer(Farmer farmer) => db.insertFarmer(farmer);

  Future<void> insertPlot(Plot plot) => db.insertPlot(plot);

  Future<int> insertTree(Tree tree) => db.insertTree(tree);

  Future<void> insertAllPlot(List<Plot> plots) => db.insertAllPlot(plots);

  Future<void> insertAllTree(List<Tree> trees) => db.insertAllTree(trees);

  Future<Farmer?> searchFarmer(int id) => db.searchFarmer(id);

  Future<Plot?> searchValidPlotById(int id) => db.searchValidPlotById(id);

  Future<List<Plot>> searchValidPlotByFarmerId(int id) => db.searchValidPlotByFarmerId(id);

  Future<List<PlotWithTrees>> fetchPlotsWithTrees(int id) => db.fetchPlotsWithTrees(id);

  Future<Tree?> searchValidTreeById(int id) => db.searchValidTreeById(id);

  Future<List<Tree>> searchValidTreeByPlotId(int id) => db.searchValidTreeByPlotId(id);

  Future<void> updatePlot(Plot plot) => db.updatePlot(plot);

  Future<void> updateTree(Tree tree) => db.updateTree(tree);

  Future<void> markPlotAsInvalid(int plotId) => db.markPlotAsInvalid(plotId);

  Future<void> markTreeAsInvalid(int treeId) => db.markTreeAsInvalid(treeId);

  Future<void> deletePlot(Plot plot) => db.deletePlot(plot);

  Future<void> deletePlotById(int id) => db.deletePlotById(id);

  Future<void> deleteTreeById(int id) => db.deleteTreeById(id);

  Future<void> deleteTree(Tree tree) => db.deleteTree(tree);

  Future<void> deleteAllPlot(List<Plot> plots) => db.deletePlotList(plots);

  Future<void> deleteAllTree(List<Tree> trees) => db.deleteTreeList(trees);

  Future<void> clear() => db.deleteAll();
}