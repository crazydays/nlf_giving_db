import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/account.dart';

import 'account_create_page.dart';
import 'account_edit_page.dart';
import 'person_page.dart';
import 'address_page.dart';

class AccountPage extends StatefulWidget {
  static const route = '/account_page';

  const AccountPage({ Key? key }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountState();
}

class _AccountState extends State<AccountPage> {
  late List<Account> _accounts;

  @override
  void initState() {
    super.initState();

    _accounts = <Account>[];

    _loadAccounts();
  }

  AccountProvider get databaseProvider => Provider.of<DatabaseProvider>(context, listen: false).accountProvider;

  void _loadAccounts() async {
    databaseProvider.all().asStream().listen((results) {
      setState(() {
        _accounts = results.toList();
      });
    });
  }

  void _delete(Account record) {
    databaseProvider.delete(record);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, database, __) {
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
                              label: Text('Name',
                                  style: TextStyle(fontWeight: FontWeight
                                      .bold))
                          ),
                          DataColumn(
                              label: Text('Actions',
                                  style: TextStyle(fontWeight: FontWeight
                                      .bold))
                          ),
                        ],
                        rows: List<DataRow>.generate(
                            _accounts.length,
                                (int index) =>
                                DataRow(
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
                                                        arguments: PersonPageArguments(
                                                            database.database,
                                                            _accounts[index])
                                                    );
                                                  },
                                                  icon: const Icon(
                                                      Icons.person)
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                        context,
                                                        AddressPage.route,
                                                        arguments: AddressPageArguments(
                                                            database.database,
                                                            _accounts[index])
                                                    );
                                                  },
                                                  icon: const Icon(
                                                      Icons.house)
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                        context,
                                                        AccountEditPage.route,
                                                        arguments: AccountEditPageArguments(
                                                            database.database,
                                                            _accounts[index])
                                                    );
                                                  },
                                                  icon: const Icon(Icons.edit)
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    _delete(_accounts[index]);
                                                  },
                                                  icon: const Icon(
                                                      Icons.delete)
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
                arguments: AccountCreatePageArguments(database.database)
            );
          },
          child: const Icon(Icons.add_circle_outline),
        ),
      );
    });
  }
}
