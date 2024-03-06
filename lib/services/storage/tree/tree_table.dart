import 'package:drift/drift.dart';
import 'package:GreenLens/services/storage/plot/plot_table.dart';

class TreeTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get uid => integer().named('uid').nullable()();
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
  TextColumn get physicalMechanism => text().named('physical_mechanism').nullable()();
  TextColumn get numTreesInMortality => text().named('num_trees_in_mortality').nullable()();
  TextColumn get killProcess => text().named('kill_process').nullable()();
  RealColumn get age => real().named('age').nullable()();
  TextColumn get species => text().named('species').nullable()();
  TextColumn get locationsJson => text().named('locations_json').nullable()();
  TextColumn get lineJson => text().named('line_json').nullable()();
  BoolColumn get isValid => boolean().named('is_valid').withDefault(Constant(true))();
}