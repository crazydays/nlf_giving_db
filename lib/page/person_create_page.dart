import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/account.dart';
import 'package:nlf_giving_db/db/person.dart';

class PersonCreatePageArguments {
  final Account account;

  const PersonCreatePageArguments(this.account);
}

class PersonCreatePage extends StatefulWidget {
  static const route = '/person_create_page';

  final Account account;

  const PersonCreatePage({ Key? key, required this.account }) : super(key: key);

  @override
  State<PersonCreatePage> createState() => _PersonCreatePageState();
}

class _PersonCreatePageState extends State<PersonCreatePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late bool? _isMaster;

  PersonProvider get personProvider => Provider.of<DatabaseProvider>(context, listen: false).personProvider;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _isMaster = false;

    initializeIsMaster();
  }

  Future<void> initializeIsMaster() async {
    personProvider.existingMasterForAccount(widget.account).asStream().listen((result) {
      setState(() {
        _isMaster = !result;
      });
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account Person: ${widget.account.name}'),
      ),
      body: Card(
          margin: const EdgeInsets.all(10.0),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'First Name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Last Name',
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          children: <Widget>[
                            const Text('Primary'),
                            Checkbox(
                                value: _isMaster,
                                onChanged: (value) {
                                  setState(() {
                                    _isMaster = value!;
                                  });
                                }
                            ),
                          ]
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _create();
                                Navigator.pop(context);
                              },
                              child: const Text('Create')
                          ),
                        ],
                      )
                  ),
                ],
              )
          )
      ),
    );
  }

  void _create() async {
    Person record = Person.fromMap({
      Person.columnAccountId: widget.account.id,
      Person.columnMaster: _isMaster,
      Person.columnFirstName: _firstNameController.value.text,
      Person.columnLastName: _lastNameController.value.text,
    });

    await personProvider.insert(record);
  }
}
