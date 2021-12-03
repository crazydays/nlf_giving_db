import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'provider.dart';
import 'model.dart';
import 'category.dart';
import 'account.dart';

class Donation implements Model {
  static const String table = 'donations';
  static const String columnId = '_id';
  static const String columnAccountId = Account.columnIdFk;
  static const String columnReceived = 'received_date';
  static const String columnDate = 'item_date';
  static const String columnCheck = 'check_number';
  static const String columnACH = 'ach_account';
  static const String columnACHTrace = 'ach_trace';
  static const String columnAmount = 'amount';
  static const String columnCategoryId = Category.columnIdFk;

  static final dateFormat = DateFormat('yyyy-MM-dd');

  static Future<void> onCreate(Database database, int version) async {
    return database.execute('''
CREATE TABLE $table (
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
  $columnAccountId INTEGER NOT NULL,
  $columnReceived TEXT NOT NULL,
  $columnDate TEXT NOT NULL,
  $columnCheck TEXT,
  $columnACH TEXT,
  $columnACHTrace TEXT,
  $columnAmount INTEGER NOT NULL,
  $columnCategoryId INTEGER NOT NULL
)''');
  }

  @override
  String getTable() {
    return table;
  }

  @override
  int? id;
  int? accountId;
  DateTime? receivedDate;
  DateTime? itemDate;
  String? checkNumber;
  String? achAccount;
  String? achTrace;
  double? amount;
  int? categoryId;

  Donation();

  Donation.fromMap(Map map) {
    id = map[columnId] as int?;
    accountId = map[columnAccountId] as int?;
    receivedDate = _parseDate(map[columnReceived]);
    itemDate = _parseDate(map[columnDate]);
    checkNumber = map[columnCheck] as String?;
    achAccount = map[columnACH] as String?;
    achTrace = map[columnACHTrace] as String?;
    amount = _parseMoney(map[columnAmount]);
    categoryId = map[columnCategoryId] as int?;
  }

  DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    } else if (value.runtimeType == DateTime) {
      return value as DateTime;
    } else if (value.runtimeType == String) {
      return dateFormat.parse(value as String);
    } else {
      print('Unknown date time type: ${value.runtimeType}');
      return null;
    }
  }

  double? _parseMoney(Object? value) {
    if (value == null) {
      return null;
    } else if (value.runtimeType == String) {
      return double.tryParse(value as String);
    } else if (value.runtimeType == int) {
      return (value as int) / 100.0;
    } else {
      return null;
    }
  }

  @override
  Map<String, Object?> toMap() {
    final map = <String, Object?> {
      columnAccountId: accountId,
      columnReceived: _formatDate(receivedDate),
      columnDate: _formatDate(itemDate),
      columnCheck: checkNumber,
      columnACH: achAccount,
      columnACHTrace: achTrace,
      columnAmount: _formatMoney(amount),
      columnCategoryId: categoryId
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    } else {
      return dateFormat.format(value);
    }
  }

  int? _formatMoney(double? value) {
    if (value == null) {
      return null;
    } else {
      return (value * 100).toInt();
    }
  }
}

class DonationProvider extends Provider<Donation> {
  DonationProvider(Database database) : super(database);

  Future<List<Map<String, Object?>>> all() async {
    return database.rawQuery('''
SELECT
    D.${Donation.columnId},
    D.${Donation.columnAccountId},
    A.${Account.columnName} AS ${Account.table}_${Account.columnName},
    D.${Donation.columnReceived},
    D.${Donation.columnDate},
    D.${Donation.columnCheck},
    D.${Donation.columnACH},
    D.${Donation.columnACHTrace},
    D.${Donation.columnAmount},
    D.${Donation.columnCategoryId},
    C.${Category.columnName} AS ${Category.table}_${Category.columnName}
  FROM
    ${Donation.table} D
    INNER JOIN ${Account.table} A ON A.${Account.columnId} = D.${Donation.columnAccountId}
    INNER JOIN ${Category.table} C ON C.${Category.columnId} = D.${Donation.columnCategoryId}
  ORDER BY D.${Donation.columnReceived} DESC, A.${Account.columnName}
    ''');
  }


  Future<List<Donation>> byAccount(Account account) async {
    return (await database.query(
      Donation.table,
      where: '${Donation.columnAccountId} = ?',
      whereArgs: [account.id],
      orderBy: '${Donation.columnReceived}, ${Donation.columnDate}'
    )).map((result) => Donation.fromMap(result)).toList();
  }

}
