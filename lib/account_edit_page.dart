import 'package:flutter/material.dart';
import 'db/giving_database.dart';
import 'db/account.dart';

class AccountEditPageArguments {
  final GivingDatabase database;
  final Account record;

  AccountEditPageArguments(this.database, this.record);
}

class AccountEditPage extends StatefulWidget {
  static const route = '/account_edit_page';

  final GivingDatabase database;
  final Account record;

  const AccountEditPage({ Key? key, required this.database, required this.record }) : super(key: key);

  @override
  State<AccountEditPage> createState() => _AccountEditState();
}

class _AccountEditState extends State<AccountEditPage> {
  late AccountProvider _provider;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Account) as AccountProvider;
    _nameController = TextEditingController(text: widget.record.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: Card(
          margin: const EdgeInsets.all(10.0),
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
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
    Account record = Account.fromMap({
      Account.columnId: widget.record.id,
      Account.columnName: _nameController.value.text,
    });

    await _provider.update(record);
  }
}
