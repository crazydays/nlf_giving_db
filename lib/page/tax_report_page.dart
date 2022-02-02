import 'package:flutter/material.dart';
import 'package:nlf_giving_db/pdf/tax_reports_generator.dart';
import '../db/giving_database.dart';

class TaxReportArguments {
  final GivingDatabase database;

  TaxReportArguments(this.database);
}

class TaxReportPage extends StatelessWidget {
  static const String route = '/tax_report';

  final GivingDatabase database;

  const TaxReportPage({ Key? key, required this.database }) : super(key: key);

  void generateTaxReports() async {
    // TODO: figure out year
    TaxReportsGenerator(database, 2021).generate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Tax Reports'),
      ),
      body: Card(
          margin: const EdgeInsets.all(10.0),
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  onPressed: () {
                    generateTaxReports();
                  },
                  child: const Text('Generate')
              )
          )
      ),
    );
  }
}
