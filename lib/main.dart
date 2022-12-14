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
      debugShowCheckedModeBanner: false,
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
                return PersonPage(account: arguments.account);
              }
          );
        } else if (settings.name == PersonCreatePage.route) {
          final arguments = settings.arguments as PersonCreatePageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return PersonCreatePage(account: arguments.account);
              }
          );
        } else if (settings.name == PersonEditPage.route) {
          final arguments = settings.arguments as PersonEditPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return PersonEditPage(account: arguments.account, record: arguments.record);
              }
          );
        } else if (settings.name == AddressPage.route) {
          final arguments = settings.arguments as AddressPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return AddressPage(account: arguments.account);
              }
          );
        } else if (settings.name == CategoryPage.route) {
          return MaterialPageRoute(
              builder: (context) {
                return const CategoryPage();
              }
          );
        } else if (settings.name == CategoryCreatePage.route) {
          return MaterialPageRoute(
              builder: (context) {
                return const CategoryCreatePage();
              }
          );
        } else if (settings.name == CategoryEditPage.route) {
          final arguments = settings.arguments as CategoryEditPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return CategoryEditPage(record: arguments.record);
              }
          );
        } else if (settings.name == DonationPage.route) {
          return MaterialPageRoute(
              builder: (context) {
                return const DonationPage();
              }
          );
        } else if (settings.name == DonationCreatePage.route) {
          return MaterialPageRoute(
              builder: (context) {
                return const DonationCreatePage();
              }
          );
        } else if (settings.name == DonationEditPage.route) {
          final arguments = settings.arguments as DonationEditPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return DonationEditPage(record: arguments.record);
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
