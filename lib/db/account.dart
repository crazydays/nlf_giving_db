import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'provider.dart';
import 'model.dart';

class Account implements Model {
  static const String table = 'accounts';
  static const String columnId = '_id';
  static const String columnName = 'name';
  static const String columnIdFk = 'account_id';

  static Future<void> onCreate(Database database, int version) async {
    return database.execute('''
CREATE TABLE $table (
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
  $columnName TEXT NOT NULL UNIQUE
)''');
  }

  @override
  String getTable() {
    return table;
  }

  @override
  int? id;
  String? name;

  Account();

  Account.fromMap(Map map) {
    id = map[columnId] as int?;
    name = map[columnName] as String?;
  }

  @override
  Map<String, Object?> toMap() {
    final map = <String, Object?> {
      columnName: name
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }
}

class AccountProvider extends Provider<Account> {
  AccountProvider(Database database) : super(database);

  Future<Iterable<Account>> all() async {
    return (await database.query(
        Account.table,
        orderBy: '${Account.columnName} ASC')).map((result) => Account.fromMap(result));
  }

}
