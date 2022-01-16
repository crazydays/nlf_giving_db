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
  static final currencyFormat = NumberFormat.currency(symbol: '\$', customPattern: '¤###,###.00;-¤###,###.00');

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
      return null;
    }
  }

  double? _parseMoney(Object? value) {
    if (value == null) {
      return null;
    } else if (value.runtimeType == String) {
      return currencyFormat.parse(value as String).toDouble();
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

  Future<List<Map<String, Object?>>> filter(String? name, DateTime? startDate, DateTime? endDate, Category? category) async {
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
    ${_filterWhereClause(name, startDate, endDate, category)}
  ORDER BY D.${Donation.columnReceived} DESC, A.${Account.columnName}
    ''',
    _filterWhereArguments(name, startDate, endDate, category));
  }

  String _filterWhereClause(String? name, DateTime? startDate, DateTime? endDate, Category? category) {
    String accumulator = '';
    if (name != null && name.isNotEmpty) {
      accumulator += 'A.${Account.columnName} LIKE ?';
    }

    if (startDate != null) {
      if (accumulator.isNotEmpty) {
        accumulator += ' AND ';
      }

      accumulator += '(D.${Donation.columnReceived} >= ? || D.${Donation.columnDate} >= ?)';
    }

    if (endDate != null) {
      if (accumulator.isNotEmpty) {
        accumulator += ' AND ';
      }

      accumulator += '(D.${Donation.columnReceived} <= ? || D.${Donation.columnDate} <= ?)';
    }

    if (category != null) {
      if (accumulator.isNotEmpty) {
        accumulator += ' AND ';
      }

      accumulator += 'D.${Donation.columnCategoryId} = ?';
    }

    return accumulator.isEmpty ? '' : 'WHERE ' + accumulator;
  }

  List<Object> _filterWhereArguments(String? name, DateTime? startDate, DateTime? endDate, Category? category) {
    List<Object> arguments = [];
    if (name != null && name.isNotEmpty) {
      arguments.add('%$name%');
    }

    if (startDate != null) {
      arguments.add(startDate);
      arguments.add(startDate);
    }

    if (endDate != null) {
      arguments.add(endDate);
      arguments.add(endDate);
    }

    if (category != null) {
      arguments.add(category.id!);
    }

    return arguments;
  }

  Future<List<Donation>> byAccountByYear(Account account, int year) async {
    String startDate = '$year-01-01';
    String endDate = '$year-12-31';

    return (await database.query(
      Donation.table,
      where: '${Donation.columnAccountId} = ? AND ${Donation.columnDate} >= ? AND ${Donation.columnDate} <= ?',
      whereArgs: [account.id, startDate, endDate],
      orderBy: Donation.columnDate
    )).map((result) => Donation.fromMap(result)).toList();
  }

}
