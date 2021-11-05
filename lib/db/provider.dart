import 'package:sqflite/sqflite.dart';
import 'model.dart';

abstract class Provider<T extends Model> {
  final Database database;

  Provider(this.database);

  Future<T> insert(T record) async {
    record.id = await database.insert(record.getTable(), record.toMap());
    return record;
  }

  Future<T> update(T record) async {
    await database.update(record.getTable(), record.toMap(),
        where: '${Model.columnId} = ?', whereArgs: [record.id!]);

    return record;
  }

  Future<T> delete(T record) async {
    await database.delete(record.getTable(),
        where: '${Model.columnId} = ?', whereArgs: [record.id]);

    record.id = null;
    return record;
  }
}