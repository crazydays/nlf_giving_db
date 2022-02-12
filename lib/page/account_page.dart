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

  AccountProvider get accountProvider => Provider.of<DatabaseProvider>(context, listen: false).accountProvider;

  @override
  void initState() {
    super.initState();

    _accounts = <Account>[];

    _loadAccounts();
  }

  void _loadAccounts() async {
    accountProvider.all().asStream().listen((results) {
      setState(() {
        _accounts = results.toList();
      });
    });
  }

  void _delete(Account record) {
    accountProvider.delete(record);
  }

  void _gotoCreateAccountPage() {
    Navigator.pushNamed(
      context,
      AccountCreatePage.route,
    );
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
            child: Padding(
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
                                                        arguments: PersonPageArguments(_accounts[index])
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
                                                        arguments: AccountEditPageArguments(_accounts[index])
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
          onPressed: () => _gotoCreateAccountPage(),
          child: const Icon(Icons.add_circle_outline),
        ),
      );
    });
  }
}
