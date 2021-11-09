import 'package:flutter/material.dart';
import 'db/giving_database.dart';
import 'db/account.dart';
import 'db/person.dart';

class PersonCreatePageArguments {
  final GivingDatabase database;
  final Account account;

  PersonCreatePageArguments(this.database, this.account);
}

class PersonCreatePage extends StatefulWidget {
  static const route = '/person_create_page';

  final GivingDatabase database;
  final Account account;

  const PersonCreatePage({ Key? key, required this.database, required this.account }) : super(key: key);

  @override
  State<PersonCreatePage> createState() => _PersonCreateState();
}

class _PersonCreateState extends State<PersonCreatePage> {
  late PersonProvider _provider;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late bool? _isMaster;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Person) as PersonProvider;
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _isMaster = false;

    _provider.existingMasterForAccount(widget.account).asStream().listen((result) {
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
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'First Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Last Name',
                      ),
                    ),
                  ),
                  Container(
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
                  Container(
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

    await _provider.insert(record);
  }
}
