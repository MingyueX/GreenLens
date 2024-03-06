import 'package:drift/drift.dart';

class DbQuery {
  DbQuery({required this.db});

  final GeneratedDatabase db;

  Future<int> insert(
      TableInfo<Table, Insertable> table,
      Insertable<Insertable> entry,
      UpsertClause<Table, Insertable<dynamic>>? onConflict) {
    return db.into(table).insert(entry, onConflict: onConflict ?? DoNothing());
  }

  Future<void> insertBatch(
      TableInfo<Table, Insertable> table,
      final List<Insertable> entries,
      UpsertClause<Table, dynamic>? onConflict) async {
    return await db.batch((batch) {
      batch.insertAll(table, entries, onConflict: onConflict ?? DoNothing());
    });
  }

  Future<void> update(
      TableInfo<Table, Insertable> table, Insertable<Insertable> entry) {
    return db.update(table).replace(entry);
  }

  Future<void> updateFieldWhere<T extends Table, D extends DataClass>({
    required TableInfo<T, D> table,
    required Expression<bool> Function(T tbl) whereCondition,
    required Insertable<D> updatedValues,
  }) async {
    final query = db.update(table)..where(whereCondition);
    await query.write(updatedValues);
  }

  Future<void> delete(
      TableInfo<Table, Insertable> table, Insertable<Insertable> entry) {
    return db.delete(table).delete(entry);
  }

  Future<void> deleteWhere(
      TableInfo<Table, Insertable> table, Function filter) {
    return (db.delete(table)..where((row) => filter(row))).go();
  }

  Future<void> deleteBatch(TableInfo<Table, Insertable> table,
      final List<Insertable> entries) async {
    return await db.batch((batch) {
      for (var entry in entries) {
        batch.delete(table, entry);
      }
    });
  }

  Future<void> deleteAll(TableInfo<Table, Insertable> table) {
    return db.delete(table).go();
  }

  Future<Insertable?> select(
      TableInfo<Table, Insertable> table, Function filter, [Function? filter2]) async {
    List<Insertable> results;
    if (filter2 != null) {
      results = await (db.select(table)
            ..where((row) => filter(row))
            ..where((row) => filter2(row)))
          .get();
      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    }
    else {
      results = await (db.select(table)
        ..where((row) => filter(row))).get();
    }
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Future<List<Insertable>> search(
  //     TableInfo<Table, Insertable> table, Function filter) async {
  //   return await (db.select(table)..where((row) => filter(row))).get();
  // }

  Future<List<Insertable>> search(
      TableInfo<Table, Insertable> table, Function filter, [Function? filter2]) async {
    if (filter2 != null) {
      return await (db.select(table)
        ..where((row) => filter(row))..where((row) => filter2(row)))
          .get();
    }
    else {
      return await (db.select(table)..where((row) => filter(row))).get();
    }
  }
}
