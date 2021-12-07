import 'package:flutter/material.dart';
import '../db/giving_database.dart';
import '../db/account.dart';
import 'account_create_page.dart';
import 'account_edit_page.dart';
import 'person_page.dart';
import 'address_page.dart';

class AccountPageArguments {
  final GivingDatabase database;

  AccountPageArguments(this.database);
}

class AccountPage extends StatefulWidget {
  static const route = '/account_page';

  final GivingDatabase database;

  const AccountPage({ Key? key, required this.database }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountState();
}

class _AccountState extends State<AccountPage> {
  late AccountProvider _provider;
  late List<Account> _accounts;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Account) as AccountProvider;
    _provider.dataChangedEvent + (e) => _loadAccounts();
    _accounts = <Account>[];

    _loadAccounts();
  }

  void _loadAccounts() async {
    _provider.all().asStream().listen((results) {
      setState(() {
        _accounts = results.toList();
      });
    });
  }

  void _delete(Account record) {
    _provider.delete(record);
  }

  @override
  void dispose() {
    _provider.dataChangedEvent - (e) => _loadAccounts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts'),
      ),
      body: Card(
          margin: const EdgeInsets.all(10.0),
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataColumn(
                            label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                      ],
                      rows: List<DataRow>.generate(
                          _accounts.length,
                              (int index) => DataRow(
                              cells: <DataCell>[
                                DataCell(
                                    Text(_accounts[index].name!)
                                ),
                                DataCell(
                                    Row(
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context,
                                                  PersonPage.route,
                                                  arguments: PersonPageArguments(widget.database, _accounts[index])
                                              );
                                            },
                                            icon: const Icon(Icons.person)
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context,
                                                  AddressPage.route,
                                                  arguments: AddressPageArguments(widget.database, _accounts[index])
                                              );
                                            },
                                            icon: const Icon(Icons.house)
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context,
                                                  AccountEditPage.route,
                                                  arguments: AccountEditPageArguments(widget.database, _accounts[index])
                                              );
                                            },
                                            icon: const Icon(Icons.edit)
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              _delete(_accounts[index]);
                                            },
                                            icon: const Icon(Icons.delete)
                                        ),
                                      ],
                                    )
                                ),
                              ]
                          )
                      )
                  )
              )
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
              context,
              AccountCreatePage.route,
              arguments: AccountCreatePageArguments(widget.database)
          );
        },
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }
}

