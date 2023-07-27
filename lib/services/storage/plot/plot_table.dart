import 'package:drift/drift.dart';

class Plot extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmerId => integer().named('farmer_id').customConstraint('REFERENCES farmer(id)')();
  IntColumn get clusterId => integer().named('cluster_id')();
  IntColumn get groupId => integer().named('group_id')();
  IntColumn get farmId => integer().named('farm_id')();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get harvesting => boolean().withDefault(Constant(false))();
  BoolColumn get thinning => boolean().withDefault(Constant(false))();
  TextColumn get dominantLandUse => text().named('dominant_land_use').withLength(min: 1, max: 50)();
}
