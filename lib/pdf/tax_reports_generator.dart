import 'tax_report_generator.dart';
import '../db/giving_database.dart';
import '../db/account.dart';

class TaxReportsGenerator {
  final GivingDatabase _database;
  final int _year;
  late AccountProvider _accountProvider;

  TaxReportsGenerator(this._database, this._year) {
    _accountProvider = _database.providers[Account] as AccountProvider;
  }

  void generate() {
    _generateAllTaxReports();
  }

  void _generateAllTaxReports() {
    _accountProvider.all().asStream().listen((accounts) {
      for (Account account in accounts) {
        _generateAccountTaxReport(account);
      }
    });
  }

  void _generateAccountTaxReport(Account account) {
    TaxReportGenerator(_database, account, _year).generate();
  }
}
