import 'dart:io';
import 'package:GreenLens/services/storage/tree/tree_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:GreenLens/services/storage/plot/plot_table.dart';
import 'package:GreenLens/services/storage/queries.dart';
import 'package:GreenLens/services/storage/farmer/farmer_table.dart';

import '../../model/models.dart';

// generated file, run "dart run build_runner build" to generate
part 'database.g.dart';

@DriftDatabase(tables: [FarmerTable, PlotTable, TreeTable])
class Database extends _$Database {
  Database._internal() : super(_openConnection());
  static final Database instance = Database._internal();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  DbQuery get dbQuery => DbQuery(db: this);

  // insert functions for farmer, plot, tree

  Future<void> insertFarmer(Farmer farmer) async {
    await dbQuery.insert(farmerTable, farmerToDb(farmer), null);
  }

  Future<void> insertPlot(Plot plot) async {
    await dbQuery.insert(plotTable, plotToDb(plot), null);
  }

  Future<int> insertTree(Tree tree) async {
    return await dbQuery.insert(treeTable, treeToDb(tree), null);
  }

  Future<void> insertAllPlot(List<Plot> plots) async {
    await dbQuery.insertBatch(plotTable, plots.map((p) => plotToDb(p)).toList(), null);
  }

  Future<void> insertAllTree(List<Tree> trees) async {
    await dbQuery.insertBatch(treeTable, trees.map((t) => treeToDb(t)).toList(), null);
  }

  Future<Farmer?> searchFarmer(int id) async {
    final farmer = await dbQuery.select(farmerTable, (f) => f.id.equals(id));
    if (farmer == null) {
      return null;
    }

    return Future.sync(() => farmerFromDb(farmer as FarmerTableData));
  }

  Future<List<PlotWithTrees>> fetchPlotsWithTrees(int participantId) async {

    final List<Plot> plots = await searchAllPlotByFarmerId(participantId);

    List<PlotWithTrees> plotsWithTrees = [];

    for (final plot in plots) {
      final List<Tree> trees = await searchAllTreeByPlotId(plot.id!);
      plotsWithTrees.add(PlotWithTrees(plot: plot, trees: trees));
    }

    return plotsWithTrees.toList();
  }


  // search functions for plot
  Future<Plot?> searchValidPlotById(int id) async {
    final plot = await dbQuery.select(plotTable, (p) => p.id.equals(id), (p) => p.isValid.equals(true));
    if (plot == null) {
      return null;
    }

    return Future.sync(() => plotFromDb(plot as PlotTableData));
  }

  Future<List<Plot>> searchValidPlotByFarmerId(int id) async {
    final plotList = await dbQuery.search(plotTable, (p) => p.farmerId.equals(id), (p) => p.isValid.equals(true));

    return Future.sync(() => (plotList.map((p) => plotFromDb(p as PlotTableData))).toList());
  }

  Future<List<Plot>> searchAllPlotByFarmerId(int id) async {
    final plotList = await dbQuery.search(plotTable, (p) => p.farmerId.equals(id));

    return Future.sync(() => (plotList.map((p) => plotFromDb(p as PlotTableData))).toList());
  }

  // Future<List<Plot>> searchPlotByClusterId(int id) async {
  //   bool filter(PlotTableData p) => p.clusterId == id && p.isValid == true;
  //   final plotList = await dbQuery.search(plotTable, (p) => filter(p));
  //
  //   return plotList.map((p) => plotFromDb(p as PlotTableData)).toList();
  // }
  //
  // Future<List<Plot>> searchPlotByGroupId(int id) async {
  //   bool filter(PlotTableData p) => p.groupId == id && p.isValid == true;
  //   final plotList = await dbQuery.search(plotTable, (p) => filter(p));
  //
  //   return Future.sync(() => (plotList.map((p) => plotFromDb(p as PlotTableData))).toList());
  // }

  // search functions for tree
  Future<Tree?> searchValidTreeById(int id) async {
    final tree = await dbQuery.select(treeTable, (t) => t.id.equals(id), (t) => t.isValid.equals(true));
    if (tree == null) {
      return null;
    }

    return Future.sync(() => treeFromDb(tree as TreeTableData));
  }

  Future<List<Tree>> searchValidTreeByPlotId(int id) async {
    final treeList = await dbQuery.search(treeTable, (t) => t.plotId.equals(id), (t) => t.isValid.equals(true));

    return Future.sync(() => (treeList.map((t) => treeFromDb(t as TreeTableData))).toList());
  }

  Future<List<Tree>> searchAllTreeByPlotId(int id) async {
    final treeList = await dbQuery.search(treeTable, (t) => t.plotId.equals(id));

    return Future.sync(() => (treeList.map((t) => treeFromDb(t as TreeTableData))).toList());
  }

  Future<void> updateFarmer(Farmer f) async {
    await dbQuery.update(farmerTable, farmerToDb(f));
  }

  Future<void> updatePlot(Plot p) async {
    await dbQuery.update(plotTable, plotToDb(p));
  }

  Future<void> updateTree(Tree t) async {
    await dbQuery.update(treeTable, treeToDb(t));
  }

  Future<void> deleteFarmer(Farmer f) async {
    await dbQuery.delete(farmerTable, farmerToDb(f));
  }

  Future<void> deletePlot(Plot p) async {
    await dbQuery.delete(plotTable, plotToDb(p));
  }

  Future<void> deletePlotById(int id) async {
    await dbQuery.deleteWhere(plotTable, (p) => p.id.equals(id));
  }

  Future<void> deleteTree(Tree t) async {
    await dbQuery.delete(treeTable, treeToDb(t));
  }

  Future<void> deleteTreeById(int id) async {
    await dbQuery.deleteWhere(treeTable, (t) => t.id.equals(id));
  }

  Future<void> deletePlotList(List<Plot> plots) async {
    await dbQuery.deleteBatch(plotTable, plots.map((p) => plotToDb(p)).toList());
  }

  Future<void> deleteTreeList(List<Tree> trees) async {
    await dbQuery.deleteBatch(treeTable, trees.map((t) => treeToDb(t)).toList());
  }

  Future<void> deleteAll() async {
    await dbQuery.deleteAll(treeTable);
    await dbQuery.deleteAll(plotTable);
    await dbQuery.deleteAll(farmerTable);
  }

  Future<void> markPlotAsInvalid(int plotId) async {
    await dbQuery.updateFieldWhere(
      table: plotTable,
      whereCondition: (tbl) => tbl.id.equals(plotId),
      updatedValues: const PlotTableCompanion(isValid: Value(false)),
    );

    await dbQuery.updateFieldWhere(
      table: treeTable,
      whereCondition: (tbl) => tbl.plotId.equals(plotId),
      updatedValues: const TreeTableCompanion(isValid: Value(false)),
    );
  }

  Future<void> markTreeAsInvalid(int treeId) async {
    await dbQuery.updateFieldWhere(
      table: treeTable,
      whereCondition: (tbl) => tbl.id.equals(treeId),
      updatedValues: const TreeTableCompanion(isValid: Value(false)),
    );
  }

  // Conversion for Farmer
  FarmerTableCompanion farmerToDb(Farmer f) {
    return FarmerTableCompanion(
      id: const Value.absent(),
      name: Value(f.name),
      participantId: Value(f.participantId),
    );
  }

  Farmer farmerFromDb(FarmerTableData f) {
    return Farmer(
      id: f.id,
      name: f.name,
      participantId: f.participantId,
    );
  }

  // Conversion for Plot
  PlotTableCompanion plotToDb(Plot p) {
    return PlotTableCompanion(
      id: p.id == null ? const Value.absent() : Value(p.id!),
      uid: Value(p.uid),
      farmerId: Value(p.farmerId),
      // clusterId: Value(p.clusterId),
      // groupId: Value(p.groupId),
      // farmId: Value(p.farmId),
      date: Value(p.date),
      harvesting: Value(p.harvesting),
      thinning: Value(p.thinning),
      dominantLandUse: Value(p.dominantLandUse),
      isValid: Value(p.isValid),
    );
  }

  Plot plotFromDb(PlotTableData p) {
    return Plot(
      id: p.id,
      uid: p.uid,
      farmerId: p.farmerId,
      // clusterId: p.clusterId,
      // groupId: p.groupId,
      // farmId: p.farmId,
      date: p.date,
      harvesting: p.harvesting,
      thinning: p.thinning,
      dominantLandUse: p.dominantLandUse,
      isValid: p.isValid,
    );
  }

  // Conversion for Tree
  TreeTableCompanion treeToDb(Tree t) {
    return TreeTableCompanion(
      id: t.id == null ? const Value.absent() : Value(t.id!),
      uid: Value(t.uid),
      plotId: Value(t.plotId),
      diameter: Value(t.diameter),
      locationLatitude: Value(t.locationLatitude),
      locationLongitude: Value(t.locationLongitude),
      orientation: Value(t.orientation),
      speciesId: Value(t.speciesId),
      isEucalyptus: Value(t.isEucalyptus),
      condition: Value(t.condition.name),
      detail: Value(t.conditionDetail?.statusCode),
      physicalMechanism: Value(t.physicalMechanism?.statusCode),
      numTreesInMortality: Value(t.numTreesInMortality?.statusCode),
      killProcess: Value(t.killProcess?.statusCode),
      causeOfDeath: Value(t.causeOfDeath),
      age: Value(t.age),
      species: Value(t.species),
      locationsJson: Value(t.locationsJson),
      lineJson: Value(t.lineJson),
      isValid: Value(t.isValid),
    );
  }

  Tree treeFromDb(TreeTableData t) {
    return Tree(
      id: t.id,
      uid: t.uid,
      plotId: t.plotId,
      diameter: t.diameter,
      locationLatitude: t.locationLatitude,
      locationLongitude: t.locationLongitude,
      orientation: t.orientation,
      speciesId: t.speciesId,
      isEucalyptus: t.isEucalyptus,
      condition: TreeCondition.fromString(t.condition),
      conditionDetail: TreeAliveCondition.fromString(t.detail),
      physicalMechanism: PhysicalMechanism.fromString(t.physicalMechanism),
      numTreesInMortality: NumTreesInMortality.fromString(t.numTreesInMortality),
      killProcess: KillProcess.fromString(t.killProcess),
      causeOfDeath: t.causeOfDeath,
      age: t.age,
      species: t.species,
      locationsJson: t.locationsJson,
      lineJson: t.lineJson,
      isValid: t.isValid,
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}