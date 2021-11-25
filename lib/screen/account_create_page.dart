import 'package:flutter/material.dart';
import '../db/giving_database.dart';
import '../db/account.dart';

class AccountCreatePageArguments {
  final GivingDatabase database;

  AccountCreatePageArguments(this.database);
}

class AccountCreatePage extends StatefulWidget {
  static const route = '/account_create_page';

  final GivingDatabase database;

  const AccountCreatePage({ Key? key, required this.database }) : super(key: key);

  @override
  State<AccountCreatePage> createState() => _AccountCreateState();
}

class _AccountCreateState extends State<AccountCreatePage> {
  late AccountProvider _provider;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Account) as AccountProvider;
    _nameController = TextEditingController();
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
        title: const Text('Create Account'),
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
    Account record = Account.fromMap({
      Account.columnName: _nameController.value.text,
    });

    await _provider.insert(record);
  }
}
