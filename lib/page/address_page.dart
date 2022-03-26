import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/account.dart';
import 'package:nlf_giving_db/db/address.dart';

class AddressPageArguments {
  final Account account;

  const AddressPageArguments(this.account);
}

class AddressPage extends StatefulWidget {
  static const route = '/address_page';

  final Account account;

  const AddressPage({ Key? key, required this.account }) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressState();
}

class _AddressState extends State<AddressPage> {
  AddressProvider get addressProvider => Provider.of<DatabaseProvider>(context, listen: false).addressProvider;

  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;

  @override
  void initState() {
    super.initState();

    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<Address> _load() async {
    Address address = await addressProvider.loadByAccount(widget.account) ?? Address();

    _address1Controller.text = address.line1 ?? '';
    _address2Controller.text = address.line2 ?? '';
    _cityController.text = address.city ?? '';
    _stateController.text = address.state ?? '';
    _postalCodeController.text = address.postalCode ?? '';

    return address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Address: ${widget.account.name}'),
      ),
      body: FutureBuilder<Address>(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot<Address> snapshot) {
          if (snapshot.hasData) {
            return Card(
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
                            controller: _address1Controller,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Address Line 1',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _address2Controller,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Address Line 2',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'City',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'State',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _postalCodeController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Postal Code',
                            ),
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
                                      _create(snapshot.data!);
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
            );
          } else {
            return const Text('Loading data...');
          }
        },
      ),
    );
  }

  void _create(Address address) async {
    if (address.id == null) {
      await addressProvider.insert(Address.fromMap({
        Address.columnAccountId: widget.account.id,
        Address.columnLine1: _address1Controller.value.text,
        Address.columnLine2: _address2Controller.value.text,
        Address.columnCity: _cityController.value.text,
        Address.columnState: _stateController.value.text,
        Address.columnPostalCode: _postalCodeController.value.text
      }));
    } else {
      await addressProvider.update(Address.fromMap({
        Address.columnId: address.id,
        Address.columnAccountId: widget.account.id,
        Address.columnLine1: _address1Controller.value.text,
        Address.columnLine2: _address2Controller.value.text,
        Address.columnCity: _cityController.value.text,
        Address.columnState: _stateController.value.text,
        Address.columnPostalCode: _postalCodeController.value.text
      }));
    }
  }
}
