import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'provider.dart';
import 'model.dart';

class Category extends Model {
  static const String table = 'categories';
  static const String columnId = '_id';
  static const String columnName = 'name';
  static const String columnActive = 'active';
  static const String columnIdFk = 'category_id';

  static Future<void> onCreate(Database database, int version) async {
    return database.execute('''
CREATE TABLE ${Category.table} (
  ${Category.columnId} INTEGER PRIMARY KEY AUTOINCREMENT, 
  ${Category.columnName} TEXT NOT NULL UNIQUE,
  ${Category.columnActive} BOOLEAN NOT NULL CHECK (${Category.columnActive} IN (0, 1))
)''');
  }

  @override
  String getTable() {
    return table;
  }

  @override
  int? id;
  String? name;
  bool? active;

  Category();

  Category.fromMap(Map map) {
    id = map[columnId] as int?;
    name = map[columnName] as String?;
    active = map[columnActive] == 1;
  }

  @override
  Map<String, Object?> toMap() {
    final map = <String, Object?> {
      columnName: name,
      columnActive: active == true ? 1 : 0
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }
}

class CategoryProvider<Category> extends Provider {
  CategoryProvider(Database database) : super(database);
}
