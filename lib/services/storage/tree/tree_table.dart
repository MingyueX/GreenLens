import 'package:drift/drift.dart';
import 'package:tree/services/storage/plot/plot_table.dart';

class TreeTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId => integer().named('plot_id').references(PlotTable, #id, onDelete: KeyAction.cascade)();
  RealColumn get diameter => real().named('diameter').nullable()();
  RealColumn get locationLatitude => real().named('location_latitude')();
  RealColumn get locationLongitude => real().named('location_longitude')();
  RealColumn get orientation => real().named('orientation').nullable()();
  IntColumn get speciesId => integer().named('species_id').nullable()();
  BoolColumn get isEucalyptus => boolean().named('is_eucalyptus').withDefault(Constant(false))();
  TextColumn get condition => text().named('condition')();
  TextColumn get detail => text().named('detail').nullable()();
  TextColumn get causeOfDeath => text().named('cause_of_death').nullable()();
}