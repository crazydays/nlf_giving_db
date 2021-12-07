import 'tax_report_generator.dart';
import '../db/giving_database.dart';
import '../db/account.dart';

class TaxReportsGenerator {
  final GivingDatabase _database;
  late AccountProvider _accountProvider;

  TaxReportsGenerator(this._database) {
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
    TaxReportGenerator(_database, account).generate();
  }
}
