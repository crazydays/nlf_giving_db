import 'package:sqflite/sqflite.dart';
import 'model.dart';
import 'package:event/event.dart';

abstract class Provider<T extends Model> {
  final Database database;
  final Event dataChangedEvent = Event();

  Provider(this.database);

  Future<T> insert(T record) async {
    record.id = await database.insert(record.getTable(), record.toMap());

    dataChangedEvent.broadcast();

    return record;
  }

  Future<T> update(T record) async {
    await database.update(record.getTable(), record.toMap(),
        where: '${Model.columnId} = ?', whereArgs: [record.id!]);

    dataChangedEvent.broadcast();

    return record;
  }

  Future<T> delete(T record) async {
    await database.delete(record.getTable(),
        where: '${Model.columnId} = ?', whereArgs: [record.id]);

    record.id = null;

    dataChangedEvent.broadcast();

    return record;
  }
}