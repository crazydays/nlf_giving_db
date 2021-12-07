import 'package:sqflite/sqflite.dart';
import 'account.dart';
import 'provider.dart';
import 'model.dart';

class Person implements Model {
  static const String table = 'people';
  static const String columnId = '_id';
  static const String columnAccountId = Account.columnIdFk;
  static const String columnMaster = 'master';
  static const String columnFirstName = 'first_name';
  static const String columnLastName = 'last_name';

  static Future<void> onCreate(Database database, int version) async {
    return database.execute('''
CREATE TABLE $table (
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
  $columnAccountId INTEGER NOT NULL,
  $columnMaster BOOLEAN NOT NULL CHECK ($columnMaster IN (0, 1)),
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
  bool? master;
  String? firstName;
  String? lastName;

  Person();

  Person.fromMap(Map map) {
    id = map[columnId] as int?;
    accountId = map[columnAccountId] as int?;
    master = !(map[columnMaster] == null || map[columnMaster] == 0 || map[columnMaster] == false);
    firstName = map[columnFirstName] as String?;
    lastName = map[columnLastName] as String?;
  }

  @override
  Map<String, Object?> toMap() {
    final map = <String, Object?> {
      columnAccountId: accountId,
      columnMaster: master,
      columnFirstName: firstName,
      columnLastName: lastName
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }
}

class PersonProvider extends Provider<Person> {
  PersonProvider(Database database) : super(database);

  Future<List<Person>> allForAccount(Account account) async {
    return (await database.query(
        Person.table,
        where: '${Person.columnAccountId} = ?',
        whereArgs: [account.id],
        orderBy: '${Person.columnMaster} DESC, ${Person.columnFirstName} ASC'
    )).map((result) => Person.fromMap(result)).toList();
  }

  Future<Person?> selectByFirstAndLastName(Account account, String firstName, String lastName) async {
    List<Person> persons = (await database.query(
        Person.table,
      where: '${Person.columnAccountId} = ? AND ${Person.columnFirstName} = ? AND ${Person.columnLastName} = ?',
      whereArgs: [account.id, firstName, lastName]
    )).map((result) => Person.fromMap(result)).toList();

    if (persons.isEmpty) {
      return null;
    } else {
      return persons.first;
    }
  }

  Future<bool> existingMasterForAccount(Account account) async {
    return (await database.query(
        Person.table,
        where: '${Person.columnAccountId} = ? AND ${Person.columnMaster} = ?',
        whereArgs: [account.id, 1])
    ).isNotEmpty;
  }

  Future<List<Person>> all() async {
    return (await database.query(
      Person.table,
      orderBy: '${Person.columnFirstName}, ${Person.columnFirstName}'
    )).map((result) => Person.fromMap(result)).toList();
  }

  Future<List<Person>> filter(String? filter) async {
    if (filter == null || filter.isEmpty) {
      return all();
    } else {
      return (await database.query(
        Person.table,
        where: '${Person.columnFirstName} LIKE ? OR ${Person.columnLastName} LIKE ?',
        whereArgs: ['%$filter%', '%$filter%'],
        orderBy: '${Person.columnMaster} DESC, ${Person.columnFirstName} ASC'
      )).map((result) => Person.fromMap(result)).toList();
    }
  }
}
