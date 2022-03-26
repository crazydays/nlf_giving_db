import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/account.dart';


class AccountCreatePage extends StatefulWidget {
  static const route = '/account_create_page';

  const AccountCreatePage({ Key? key }) : super(key: key);

  @override
  State<AccountCreatePage> createState() => _AccountCreateState();
}

class _AccountCreateState extends State<AccountCreatePage> {
  late TextEditingController _nameController;

  AccountProvider get accountProvider => Provider.of<DatabaseProvider>(context, listen: false).accountProvider;

  @override
  void initState() {
    super.initState();

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
          child: Padding(
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
    Account record = Account.fromMap({
      Account.columnName: _nameController.value.text,
    });

    await accountProvider.insert(record);
  }
}
