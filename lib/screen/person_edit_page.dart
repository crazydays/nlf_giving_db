import 'package:flutter/material.dart';
import '../db/giving_database.dart';
import '../db/account.dart';
import '../db/person.dart';

class PersonEditPageArguments {
  final GivingDatabase database;
  final Account account;
  final Person record;

  PersonEditPageArguments(this.database, this.account, this.record);
}

class PersonEditPage extends StatefulWidget {
  static const route = '/person_edit_page';

  final GivingDatabase database;
  final Account account;
  final Person record;

  const PersonEditPage({ Key? key, required this.database, required this.account, required this.record }) : super(key: key);

  @override
  State<PersonEditPage> createState() => _PersonEditState();
}

class _PersonEditState extends State<PersonEditPage> {
  late PersonProvider _provider;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late bool? _isMaster;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Person) as PersonProvider;
    _firstNameController = TextEditingController(text: widget.record.firstName);
    _lastNameController = TextEditingController(text: widget.record.lastName);
    _isMaster = widget.record.master;
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
        title: Text('Edit Account Person: ${widget.account.name}'),
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
                                _update();
                                Navigator.pop(context);
                              },
                              child: const Text('Update')
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

  void _update() async {
    Person record = Person.fromMap({
      Person.columnId: widget.record.id,
      Person.columnAccountId: widget.account.id,
      Person.columnMaster: _isMaster,
      Person.columnFirstName: _firstNameController.value.text,
      Person.columnLastName: _lastNameController.value.text,
    });

    await _provider.update(record);
  }
}
