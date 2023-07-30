import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:tree/services/storage/plot/plot_table.dart';
import 'package:tree/services/storage/queries.dart';
import 'package:tree/services/storage/tree/tree_table.dart';
import 'package:tree/services/storage/farmer/farmer_table.dart';

// generated file, run "dart run build_runner build" to generate
part 'database.g.dart';

@DriftDatabase(tables: [Farmer, Plot, Tree])
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  DbQuery get dbQuery => DbQuery(db: this);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}