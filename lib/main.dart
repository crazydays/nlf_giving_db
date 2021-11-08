import 'package:flutter/material.dart';
import 'db/giving_database.dart';
import 'account_page.dart';
import 'account_create_page.dart';
import 'account_edit_page.dart';
import 'category_page.dart';
import 'category_create_page.dart';
import 'category_edit_page.dart';

void main() {
  runApp(const MyApp());
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
