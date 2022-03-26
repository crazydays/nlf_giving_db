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
  AccountProvider get accountProvider => Provider.of<DatabaseProvider>(context, listen: false).accountProvider;

  Future<List<Account>> _load() async {
    return accountProvider.all();
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

  void _gotoPersonPage(Account account) {
    Navigator.pushNamed(
        context,
        PersonPage.route,
        arguments: PersonPageArguments(account)
    );
  }

  void _gotoAddressPage(Account account) {
    Navigator.pushNamed(
        context,
        AddressPage.route,
        arguments: AddressPageArguments(account)
    );
  }

  void _gotoEditAccountPage(Account account) {
    Navigator.pushNamed(
        context,
        AccountEditPage.route,
        arguments: AccountEditPageArguments(account)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, database, __) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Accounts'),
          actions: [
            IconButton(
              onPressed: () => _gotoCreateAccountPage(),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        body: FutureBuilder<List<Account>>(
          future: _load(),
          builder: (BuildContext context, AsyncSnapshot<List<Account>> snapshot) {
            if (snapshot.hasData) {
              return PaginatedDataTable(
                source: _AccountDataTableSource(snapshot.data!, _gotoPersonPage, _gotoAddressPage, _gotoEditAccountPage, _delete),
                columns: const <DataColumn>[
                  DataColumn(
                      label: Text('Name',
                          style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                  DataColumn(
                      label: Text('Actions',
                          style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                ],
                columnSpacing: 100,
                horizontalMargin: 10,
                rowsPerPage: _calculateRows(),
              );
            } else {
              return const Text('Loading data...');
            }
          },
        ),
      );
    });
  }

  int _calculateRows() {
    return (MediaQuery.of(context).size.height - 180) ~/ 48;
  }
}

class _AccountDataTableSource extends DataTableSource {
  final List<Account> _data;
  final Function _people;
  final Function _address;
  final Function _edit;
  final Function _delete;

  _AccountDataTableSource(this._data, this._people, this._address, this._edit, this._delete);

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(
        cells: <DataCell>[
          DataCell(
              Text(_data[index].name!)
          ),
          DataCell(
              Row(
                children: <Widget>[
                  IconButton(
                      onPressed: () => _people(_data[index]),
                      icon: const Icon(Icons.people)
                  ),
                  IconButton(
                      onPressed: () => _address(_data[index]),
                      icon: const Icon(Icons.house)
                  ),
                  IconButton(
                      onPressed: () => _edit(_data[index]),
                      icon: const Icon(Icons.edit)
                  ),
                  IconButton(
                      onPressed: () => _delete(_data[index]),
                      icon: const Icon(Icons.delete)
                  ),
                ],
              )
          ),
        ]
    );
  }
}
