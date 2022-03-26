import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/page/account_page.dart';
import 'package:nlf_giving_db/page/category_page.dart';
import 'package:nlf_giving_db/page/donation_page.dart';
import 'package:nlf_giving_db/page/tax_report_page.dart';
import 'package:nlf_giving_db/page/import_csv_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, database, _) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Giving Database'),
            actions: [
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                onSelected: (index) {
                  switch (index) {
                    case 'accounts':
                      Navigator.pushNamed(context, AccountPage.route);
                      break;
                    case 'categories':
                      Navigator.pushNamed(context, CategoryPage.route);
                      break;
                    case 'donations':
                      Navigator.pushNamed(context, DonationPage.route);
                      break;
                    case 'tax_reports':
                      Navigator.pushNamed(context, TaxReportPage.route, arguments: TaxReportArguments(database.database));
                      break;
                    case 'import_csv':
                      Navigator.pushNamed(context, ImportCsvPage.route, arguments: ImportCsvArguments(database.database));
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      child: Text('Accounts'),
                      value: 'accounts'
                  ),
                  const PopupMenuItem(
                      child: Text('Categories'),
                      value: 'categories'
                  ),
                  const PopupMenuItem(
                      child: Text('Donations'),
                      value: 'donations'
                  ),
                  const PopupMenuItem(
                      child: Text('Tax Reports'),
                      value: 'tax_reports'
                  ),
                  const PopupMenuItem(
                      child: Text('Import Csv'),
                      value: 'import_csv'
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: const <Widget>[
            ],
          )
      );
    });
  }
}
