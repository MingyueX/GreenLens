import 'package:tree/services/storage/database.dart';

import '../../model/models.dart';

class DatabaseService {
  final Database db = Database.instance;

  Future<void> insertFarmer(Farmer farmer) => db.insertFarmer(farmer);

  Future<void> insertPlot(Plot plot) => db.insertPlot(plot);

  Future<void> insertTree(Tree tree) => db.insertTree(tree);

  Future<void> insertAllPlot(List<Plot> plots) => db.insertAllPlot(plots);

  Future<void> insertAllTree(List<Tree> trees) => db.insertAllTree(trees);

  Future<Plot?> searchPlotById(int id) => db.searchPlotById(id);

  Future<List<Plot>> searchPlotByFarmerId(int id) => db.searchPlotByFarmerId(id);

  Future<List<Plot>> searchPlotByClusterId(int id) => db.searchPlotByClusterId(id);

  Future<Tree?> searchTreeById(int id) => db.searchTreeById(id);

  Future<List<Tree>> searchTreeByPlotId(int id) => db.searchTreeByPlotId(id);

  Future<List<Tree>> searchTreeBySpeciesId(int id) => db.searchTreeBySpeciesId(id);

  Future<List<Tree>> searchTreeByTreeCondition(TreeCondition cond) => db.searchTreeByTreeCondition(cond);

  Future<List<Tree>> searchTreeByDiameter(int minDiameter, int maxDiameter) => db.searchTreeByDiameter(minDiameter, maxDiameter);

  Future<void> updatePlot(Plot plot) => db.updatePlot(plot);

  Future<void> updateTree(Tree tree) => db.updateTree(tree);

  Future<void> deletePlot(Plot plot) => db.deletePlot(plot);

  Future<void> deletePlotById(int id) => db.deletePlotById(id);

  Future<void> deleteTreeById(int id) => db.deleteTreeById(id);

  Future<void> deleteTree(Tree tree) => db.deleteTree(tree);

  Future<void> deleteAllPlot(List<Plot> plots) => db.deletePlotList(plots);

  Future<void> deleteAllTree(List<Tree> trees) => db.deleteTreeList(trees);

  Future<void> clear() => db.deleteAll();
}