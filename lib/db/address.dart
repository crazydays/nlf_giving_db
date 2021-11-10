import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'provider.dart';
import 'model.dart';
import 'account.dart';

class Address implements Model {
  static const String table = 'addresses';
  static const String columnId = '_id';
  static const String columnAccountId = Account.columnIdFk;
  static const String columnLine1 = 'address_1';
  static const String columnLine2 = 'address_2';
  static const String columnCity = 'city';
  static const String columnState = 'state';
  static const String columnPostalCode = 'postal_code';

  static Future<void> onCreate(Database database, int version) async {
    return database.execute('''
CREATE TABLE $table (
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
  $columnAccountId INTEGER NOT NULL,
  $columnLine1 TEXT NOT NULL,
  $columnLine2 TEXT NOT NULL,
  $columnCity TEXT NOT NULL,
  $columnState TEXT NOT NULL,
  $columnPostalCode TEXT NOT NULL
)''');
  }

  @override
  String getTable() {
    return table;
  }

  @override
  int? id;
  int? accountId;
  String? line1;
  String? line2;
  String? city;
  String? state;
  String? postalCode;

  Address();

  Address.fromMap(Map map) {
    id = map[columnId] as int?;
    accountId = map[columnAccountId] as int?;
    line1 = map[columnLine1] as String?;
    line2 = map[columnLine2] as String?;
    city = map[columnCity] as String?;
    state = map[columnState] as String?;
    postalCode = map[columnPostalCode] as String?;
  }

  @override
  Map<String, Object?> toMap() {
    final map = <String, Object?> {
      columnAccountId: accountId,
      columnLine1: line1,
      columnLine2: line2,
      columnCity: city,
      columnState: state,
      columnPostalCode: postalCode
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }
}

class AddressProvider extends Provider<Address> {
  AddressProvider(Database database) : super(database);

  Future<Address?> loadByAccount(Account account) async {
    List<Map<String, Object?>> results = await database.query(
        Address.table,
        where: '${Address.columnAccountId} = ?',
        whereArgs: [account.id]
    );

    if (results.isEmpty) {
      return null;
    } else {
      return Address.fromMap(results.first);
    }
  }
}
