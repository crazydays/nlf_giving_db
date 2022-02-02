import 'package:flutter/material.dart';
import '../db/giving_database.dart';
import '../db/account.dart';
import '../db/address.dart';

class AddressPageArguments {
  final GivingDatabase database;
  final Account account;

  AddressPageArguments(this.database, this.account);
}

class AddressPage extends StatefulWidget {
  static const route = '/address_page';

  final GivingDatabase database;
  final Account account;

  const AddressPage({ Key? key, required this.database, required this.account }) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressState();
}

class _AddressState extends State<AddressPage> {
  late AddressProvider _provider;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late Address _address;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Address) as AddressProvider;
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
    _address = Address();

    _loadAddress();
  }

  void _loadAddress() async {
    _provider.loadByAccount(widget.account).asStream().listen((address) {
      if (address != null) {
        setState(() {
          _address = address;
          _address1Controller.text = _address.line1 == null ? '' : _address.line1!;
          _address2Controller.text = _address.line2 == null ? '' : _address.line2!;
          _cityController.text = _address.city == null ? '' : _address.city!;
          _stateController.text = _address.state == null ? '' : _address.state!;
          _postalCodeController.text = _address.postalCode == null ? '' : _address.postalCode!;
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Address: ${widget.account.name}'),
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
                      controller: _address1Controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Address Line 1',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _address2Controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Address Line 2',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'City',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'State',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Postal Code',
                      ),
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
    if (_address.id == null) {
      await _provider.insert(Address.fromMap({
        Address.columnAccountId: widget.account.id,
        Address.columnLine1: _address1Controller.value.text,
        Address.columnLine2: _address2Controller.value.text,
        Address.columnCity: _cityController.value.text,
        Address.columnState: _stateController.value.text,
        Address.columnPostalCode: _postalCodeController.value.text
      }));
    } else {
      await _provider.update(Address.fromMap({
        Address.columnId: _address.id,
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
