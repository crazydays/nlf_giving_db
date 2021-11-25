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
CREATE TABLE $table (
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
  $columnName TEXT NOT NULL UNIQUE,
  $columnActive BOOLEAN NOT NULL CHECK ($columnActive IN (0, 1))
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
    active = !(map[columnActive] == null || map[columnActive] == 0 || map[columnActive] == false);
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

class CategoryProvider extends Provider<Category> {
  CategoryProvider(Database database) : super(database);

  Future<Category?> select(int id) async {
    return (await database.query(
        Category.table,
        where: '${Category.columnId} = ?',
        whereArgs: [id]
    )).map((result) => Category.fromMap(result)).first;
  }

  Future<Iterable<Category>> all() async {
    return (await database.query(Category.table)).map((result) => Category.fromMap(result));
  }

  Future<List<Category>> active() async {
    return (await database.query(
        Category.table, where: '${Category.columnActive} = ?', whereArgs: [1])).map(
            (result) => Category.fromMap(result)
    ).toList();
  }

  Future<List<Category>> activeByFilter(String? filter) async {
    if (filter == null || filter.isEmpty) {
      return active();
    } else {
      return (await database.query(
          Category.table,
          where: '${Category.columnActive} = ? AND ${Category.columnName} LIKE ?',
          whereArgs: [1, '%$filter%']
      )).map((result) => Category.fromMap(result)).toList();
    }
  }
}
