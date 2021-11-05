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

  static final dateFormat = DateFormat('YYYY-MM-DD');

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
    receivedDate = _parseDate(map[columnReceived] as String?);
    itemDate = _parseDate(map[columnDate] as String?);
    checkNumber = map[columnCheck] as String?;
    achAccount = map[columnACH] as String?;
    achTrace = map[columnACHTrace] as String?;
    amount = _parseMoney(map[columnAmount] as int?);
    categoryId = map[columnCategoryId] as int?;
  }

  DateTime? _parseDate(String? value) {
    if (value == null) {
      return null;
    } else {
      return dateFormat.parse(value);
    }
  }

  double? _parseMoney(int? value) {
    if (value == null) {
      return null;
    } else {
      return value / 100.0;
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

class DonationProvider<Donation> extends Provider {
  DonationProvider(Database database) : super(database);
}
