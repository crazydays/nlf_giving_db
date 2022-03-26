import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/account.dart';
import 'package:nlf_giving_db/db/person.dart';

import 'person_create_page.dart';
import 'person_edit_page.dart';


class PersonPageArguments {
  final Account account;

  const PersonPageArguments(this.account);
}

class PersonPage extends StatefulWidget {
  static const route = '/person_page';

  final Account account;

  const PersonPage({ Key? key, required this.account }) : super(key: key);

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  PersonProvider get personProvider => Provider.of<DatabaseProvider>(context, listen: false).personProvider;

  Future<List<Person>> _load() {
    return personProvider.allForAccount(widget.account);
  }

  void _edit(Person record) {
    Navigator.pushNamed(
        context,
        PersonEditPage.route,
        arguments: PersonEditPageArguments(widget.account, record)
    );
  }

  void _delete(Person record) {
    personProvider.delete(record);
  }

  void _gotoCreatePerson() {
    Navigator.pushNamed(
        context,
        PersonCreatePage.route,
        arguments: PersonCreatePageArguments(widget.account)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, database, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Manage Account People: ${widget.account.name}'),
          actions: [
            IconButton(
              onPressed: () => _gotoCreatePerson(),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        body: FutureBuilder<List<Person>>(
          future: _load(),
          builder: (BuildContext context, AsyncSnapshot<List<Person>> snapshot) {
            if (snapshot.hasData) {
              return PaginatedDataTable(
                source: _PersonDataTableSource(snapshot.data!, _edit, _delete),
                columns: const [
                  DataColumn(
                      label: Text('Primary', style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                  DataColumn(
                      label: Text('First Name', style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                  DataColumn(
                      label: Text('Last Name', style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                  DataColumn(
                      label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))
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

class _PersonDataTableSource extends DataTableSource {
  final List<Person> _data;
  final Function _edit;
  final Function _delete;

  _PersonDataTableSource(this._data, this._edit, this._delete);

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(
        cells: [
          DataCell(
              Icon(_data[index].master! ? Icons.star : Icons.star_outline)
          ),
          DataCell(
              Text(_data[index].firstName!)
          ),
          DataCell(
              Text(_data[index].lastName!)
          ),
          DataCell(
              Row(
                children: <Widget>[
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
