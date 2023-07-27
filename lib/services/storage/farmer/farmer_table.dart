import 'package:drift/drift.dart';

class Farmer extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get participantId => integer().named('participant_id')();
}