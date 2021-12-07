import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/giving_database.dart';
import 'screen/account_page.dart';
import 'screen/account_create_page.dart';
import 'screen/account_edit_page.dart';
import 'screen/person_page.dart';
import 'screen/person_create_page.dart';
import 'screen/person_edit_page.dart';
import 'screen/address_page.dart';
import 'screen/category_page.dart';
import 'screen/category_create_page.dart';
import 'screen/category_edit_page.dart';
import 'screen/donation_page.dart';
import 'screen/donation_create_page.dart';
import 'screen/donation_edit_page.dart';
import 'screen/tax_report_page.dart';
import 'screen/import_csv_page.dart';

void main() {
  runApp(
      ChangeNotifierProvider(
          create: (context) => null,
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
          final arguments = settings.arguments as AccountPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return AccountPage(database: arguments.database);
              }
          );
        } else if (settings.name == AccountCreatePage.route) {
          final arguments = settings.arguments as AccountCreatePageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return AccountCreatePage(database: arguments.database);
              }
          );
        } else if (settings.name == AccountEditPage.route) {
          final arguments = settings.arguments as AccountEditPageArguments;
          return MaterialPageRoute(
              builder: (context) {
                return AccountEditPage(database: arguments.database, record: arguments.record);
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
      title: 'New Life Fellowship Giving Database',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'New Life Fellowship Giving Database'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GivingDatabase database = GivingDatabase('zdatabase');
  bool open = false;

  @override
  void initState() {
    super.initState();

    database.open().asStream().listen((event) {
      _opened();
    });
  }

  void _opened() {
    setState(() { open = true; });
  }

  @override
  void dispose() {
    database.close().asStream().listen((event) {
      _closed();
    });

    super.dispose();
  }

  void _closed() {
    setState(() {
      open = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (index) {
                switch (index) {
                  case 'accounts':
                    Navigator.pushNamed(context, AccountPage.route, arguments: AccountPageArguments(database));
                    break;
                  case 'categories':
                    Navigator.pushNamed(context, CategoryPage.route, arguments: CategoryPageArguments(database));
                    break;
                  case 'donations':
                    Navigator.pushNamed(context, DonationPage.route, arguments: DonationArguments(database));
                    break;
                  case 'tax_reports':
                    Navigator.pushNamed(context, TaxReportPage.route, arguments: TaxReportArguments(database));
                    break;
                  case 'import_csv':
                    Navigator.pushNamed(context, ImportCsvPage.route, arguments: ImportCsvArguments(database));
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
  }
}
