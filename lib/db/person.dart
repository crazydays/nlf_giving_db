import 'package:sqflite/sqflite.dart';
import 'account.dart';
import 'provider.dart';
import 'model.dart';

class Person implements Model {
  static const String table = 'people';
  static const String columnId = '_id';
  static const String columnAccountId = Account.columnIdFk;
  static const String columnFirstName = 'first_name';
  static const String columnLastName = 'last_name';

  static Future<void> onCreate(Database database, int version) async {
    return database.execute('''
CREATE TABLE $table (
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
  $columnAccountId INTEGER NOT NULL,
  $columnFirstName TEXT NOT NULL,
  $columnLastName TEXT NOT NULL
)''');
  }

  @override
  String getTable() {
    return table;
  }

  @override
  int? id;
  int? accountId;
  String? firstName;
  String? lastName;

  Person();

  Person.fromMap(Map map) {
    id = map[columnId] as int?;
    accountId = map[columnAccountId] as int?;
    firstName = map[columnFirstName] as String?;
    lastName = map[columnLastName] as String?;
  }

  @override
  Map<String, Object?> toMap() {
    final map = <String, Object?> {
      columnAccountId: accountId,
      columnFirstName: firstName,
      columnLastName: lastName
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }
}

class PersonProvider<Person> extends Provider {
  PersonProvider(Database database) : super(database);
}
