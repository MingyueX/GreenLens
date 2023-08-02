import 'package:drift/drift.dart';

class FarmerTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get participantId => integer().named('participant_id').unique()();
}