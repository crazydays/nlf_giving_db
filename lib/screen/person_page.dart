import 'package:flutter/material.dart';
import '../db/giving_database.dart';
import '../db/account.dart';
import '../db/person.dart';
import 'person_create_page.dart';
import 'person_edit_page.dart';

class PersonPageArguments {
  final GivingDatabase database;
  final Account account;

  PersonPageArguments(this.database, this.account);
}

class PersonPage extends StatefulWidget {
  static const route = '/person_page';

  final GivingDatabase database;
  final Account account;

  const PersonPage({ Key? key, required this.database, required this.account }) : super(key: key);

  @override
  State<PersonPage> createState() => _PersonState();
}

class _PersonState extends State<PersonPage> {
  late PersonProvider _provider;
  late List<Person> _persons;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Person) as PersonProvider;
    _provider.dataChangedEvent + (e) => _loadPersons();
    _persons = <Person>[];

    _loadPersons();
  }

  void _loadPersons() async {
    _provider.allForAccount(widget.account).asStream().listen((results) {
      setState(() {
        _persons = results.toList();
      });
    });
  }

  void _delete(Person record) {
    _provider.delete(record);
  }

  @override
  void dispose() {
    _provider.dataChangedEvent - (e) => _loadPersons();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Account People: ${widget.account.name}'),
      ),
      body: Card(
          margin: const EdgeInsets.all(10.0),
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: DataTable(
                  columns: const <DataColumn>[
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
                  rows: List<DataRow>.generate(
                      _persons.length,
                          (int index) => DataRow(
                          cells: <DataCell>[
                            DataCell(
                                Icon(_persons[index].master! ? Icons.star : Icons.star_outline)
                            ),
                            DataCell(
                                Text(_persons[index].firstName!)
                            ),
                            DataCell(
                                Text(_persons[index].lastName!)
                            ),
                            DataCell(
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context,
                                              PersonEditPage.route,
                                              arguments: PersonEditPageArguments(widget.database, widget.account, _persons[index])
                                          );
                                        },
                                        icon: const Icon(Icons.edit)
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          _delete(_persons[index]);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
              context,
              PersonCreatePage.route,
              arguments: PersonCreatePageArguments(widget.database, widget.account)
          );
        },
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }
}
