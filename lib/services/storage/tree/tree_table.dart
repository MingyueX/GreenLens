import 'package:drift/drift.dart';

class Tree extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId => integer().named('plot_id').customConstraint('REFERENCES plot(id)')();
  RealColumn get diameter => real().nullable()();
  RealColumn get locationLatitude => real().named('location_latitude')();
  RealColumn get locationLongitude => real().named('location_longitude')();
  RealColumn get orientationX => real().named('orientation_x').nullable()();
  RealColumn get orientationY => real().named('orientation_y').nullable()();
  RealColumn get orientationZ => real().named('orientation_z').nullable()();
  IntColumn get speciesId => integer().named('species_id').nullable()();
  BoolColumn get isEucalyptus => boolean().named('is_eucalyptus').withDefault(Constant(false))();
  TextColumn get condition => text().withLength(min: 1, max: 50)();
  IntColumn get age => integer().nullable()();
  BoolColumn get treeFound => boolean().named('tree_found').withDefault(Constant(true))();
  TextColumn get causeOfDeath => text().named('cause_of_death').nullable()();
}