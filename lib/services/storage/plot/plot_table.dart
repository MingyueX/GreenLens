import 'package:drift/drift.dart';
import 'package:GreenLens/services/storage/farmer/farmer_table.dart';

class PlotTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get uid => integer().named('uid').nullable()();
  IntColumn get farmerId => integer().named('farmer_id').references(FarmerTable, #participantId, onDelete: KeyAction.cascade)();
  // IntColumn get clusterId => integer().named('cluster_id')();
  // IntColumn get groupId => integer().named('group_id')();
  // IntColumn get farmId => integer().named('farm_id')();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get harvesting => boolean().withDefault(const Constant(false)).named('harvesting')();
  BoolColumn get thinning => boolean().withDefault(const Constant(false)).named('thinning')();
  TextColumn get dominantLandUse => text().named('dominant_land_use')();
  BoolColumn get isValid => boolean().withDefault(const Constant(true)).named('is_valid')();
}
