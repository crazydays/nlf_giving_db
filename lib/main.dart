import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nlf_giving_db/provider/database_provider.dart';

import 'package:nlf_giving_db/page/splash_page.dart';
import 'package:nlf_giving_db/page/account_page.dart';
import 'package:nlf_giving_db/page/account_create_page.dart';
import 'package:nlf_giving_db/page/account_edit_page.dart';
import 'package:nlf_giving_db/page/person_page.dart';
import 'package:nlf_giving_db/page/person_create_page.dart';
import 'package:nlf_giving_db/page/person_edit_page.dart';
import 'package:nlf_giving_db/page/address_page.dart';
import 'package:nlf_giving_db/page/category_page.dart';
import 'package:nlf_giving_db/page/category_create_page.dart';
import 'package:nlf_giving_db/page/category_edit_page.dart';
import 'package:nlf_giving_db/page/donation_page.dart';
import 'package:nlf_giving_db/page/donation_create_page.dart';
import 'package:nlf_giving_db/page/donation_edit_page.dart';
import 'package:nlf_giving_db/page/tax_report_page.dart';
import 'package:nlf_giving_db/page/import_csv_page.dart';

void main() {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (context) => DatabaseProvider()
            ),
          ],
          child: const MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == AccountPage.route) {
          return MaterialPageRoute(
              builder: (context) {
                return const AccountPage();
              }
          );
        } else if (settings.name == AccountCreatePage.route) {
          return MaterialPageRoute(
              builder: (context) {
                return const AccountCreatePage();
              }
          );
        } else if (settings.name == AccountEditPage.route) {
          final arguments = settings.arguments as AccountEditPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return AccountEditPage(record: arguments.record);
              }
          );
        } else if (settings.name == PersonPage.route) {
          final arguments = settings.arguments as PersonPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return PersonPage(database: arguments.database, account: arguments.account);
              }
          );
        } else if (settings.name == PersonCreatePage.route) {
          final arguments = settings.arguments as PersonCreatePageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return PersonCreatePage(database: arguments.database, account: arguments.account);
              }
          );
        } else if (settings.name == PersonEditPage.route) {
          final arguments = settings.arguments as PersonEditPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return PersonEditPage(database: arguments.database, account: arguments.account, record: arguments.record);
              }
          );
        } else if (settings.name == AddressPage.route) {
          final arguments = settings.arguments as AddressPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return AddressPage(database: arguments.database, account: arguments.account);
              }
          );
        } else if (settings.name == CategoryPage.route) {
          final arguments = settings.arguments as CategoryPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return CategoryPage(database: arguments.database);
              }
          );
        } else if (settings.name == CategoryCreatePage.route) {
          final arguments = settings.arguments as CategoryCreatePageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return CategoryCreatePage(database: arguments.database);
              }
          );
        } else if (settings.name == CategoryEditPage.route) {
          final arguments = settings.arguments as CategoryEditPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return CategoryEditPage(database: arguments.database, record: arguments.record);
              }
          );
        } else if (settings.name == DonationPage.route) {
          final arguments = settings.arguments as DonationArguments;
          return MaterialPageRoute(
              builder: (context) {
                return DonationPage(database: arguments.database);
              }
          );
        } else if (settings.name == DonationCreatePage.route) {
          final arguments = settings.arguments as DonationCreatePageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return DonationCreatePage(database: arguments.database);
              }
          );
        } else if (settings.name == DonationEditPage.route) {
          final arguments = settings.arguments as DonationEditPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return DonationEditPage(database: arguments.database, record: arguments.record);
              }
          );
        } else if (settings.name == TaxReportPage.route) {
          final arguments = settings.arguments as TaxReportArguments;
          return MaterialPageRoute(
              builder: (context) {
                return TaxReportPage(database: arguments.database);
              }
          );
        } else if (settings.name == ImportCsvPage.route) {
          final arguments = settings.arguments as ImportCsvArguments;
          return MaterialPageRoute(
              builder: (context) {
                return ImportCsvPage(database: arguments.database);
              }
          );
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashPage(),
    );
  }
}
