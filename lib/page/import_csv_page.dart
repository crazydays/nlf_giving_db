import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

import '../db/giving_database.dart';
import '../db/account.dart';
import '../db/person.dart';
import '../db/address.dart';
import '../db/category.dart';
import '../db/donation.dart';

class ImportCsvArguments {
  final GivingDatabase database;

  ImportCsvArguments(this.database);
}

class ImportCsvPage extends StatefulWidget {
  static const route = '/import_csv_page';

  final GivingDatabase database;

  const ImportCsvPage({ Key? key, required this.database }) : super(key: key);

  @override
  State<ImportCsvPage> createState() => _ImportCsvState();
}

class _ImportCsvState extends State<ImportCsvPage> {
  final _accountFormKey = GlobalKey<FormState>();
  final _personFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _categoryFormKey = GlobalKey<FormState>();
  final _donationFormKey = GlobalKey<FormState>();

  late List<List<dynamic>> _data;
  late bool _skipFirstRow = true;
  late Map<String, int?> _accountMapping;
  late Map<String, int?> _personMapping;
  late Map<String, int?> _addressMapping;
  late Map<String, int?> _categoryMapping;
  late Map<String, int?> _donationMapping;

  late AccountProvider _accountProvider;
  late PersonProvider _personProvider;
  late AddressProvider _addressProvider;
  late CategoryProvider _categoryProvider;
  late DonationProvider _donationProvider;

  @override
  void initState() {
    super.initState();

    _data = [];
    _accountMapping = {};
    _personMapping = {};
    _addressMapping = {};
    _categoryMapping = {};
    _donationMapping = {};

    _accountProvider = widget.database.providers[Account] as AccountProvider;
    _personProvider = widget.database.providers[Person] as PersonProvider;
    _addressProvider = widget.database.providers[Address] as AddressProvider;
    _categoryProvider = widget.database.providers[Category] as CategoryProvider;
    _donationProvider = widget.database.providers[Donation] as DonationProvider;
  }

  void _selectAndOpenCsv() async {
    File? csvFile = await _selectFile();

    if (csvFile != null) {
      _loadCsvFile(csvFile);
    }
  }

  Future<File?> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv']
    );

    if (result == null) {
      return null;
    } else {
      return File(result.files.single.path!);
    }
  }

  void _loadCsvFile(File file) async {
    final input = file.openRead();
    final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

    setState(() {
      _data = fields;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Import CSV'),
        ),
        body: Card(
            child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    children: [
                      _tableMappings(),
                      _dataTable(),
                    ]
                )
            )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _selectAndOpenCsv(),
          child: const Icon(Icons.file_upload_outlined),
      ),
    );
  }

  Widget _tableMappings() {
    return DefaultTabController(
      length: 5,
      child: Column(
          children: [
            TabBar(
              labelColor: Colors.blue,
              tabs: [
                _accountTab(),
                _peopleTab(),
                _addressTab(),
                _categoryTab(),
                _donationTab(),
              ],
            ),
            SizedBox(
              height: 400,
              child: TabBarView(
                  children: [
                    _accountTabView(),
                    _peopleTabView(),
                    _addressTabView(),
                    _categoryTabView(),
                    _donationTabView(),
                  ]
              ),
            ),
          ]
      ),
    );
  }

  Tab _accountTab() {
    return const Tab(text: 'Account');
  }

  Widget _accountTabView() {
    return Form(
        key: _accountFormKey,
        child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int>(
                      value: _accountMapping[Account.columnName],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 20,
                      elevation: 12,
                      onChanged: (int? value) {
                        setState(() {
                          _accountMapping[Account.columnName] = value;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(i.toString()),
                        );
                      })
                  ),

                ),
              ),
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          children: <Widget>[
                            const Text('Skip First Row'),
                            Checkbox(
                                value: _skipFirstRow,
                                onChanged: (value) {
                                  setState(() {
                                    _skipFirstRow = value!;
                                  });
                                }
                            ),
                          ]
                      )
                  ),
                  ElevatedButton(
                      onPressed: () => _importAccounts(),
                      child: const Text('Import')
                  ),
                ]
              ),
            ]
        )
    );
  }

  void _importAccounts() async {
    for (var row in _data.skip(_skipFirstRow ? 1 : 0)) {
      var name = row[_accountMapping[Account.columnName]!];
      Account? account = await _accountProvider.selectByName(name);

      account ??= await _accountProvider.insert(Account.fromMap({
        Account.columnName: name
      }));
    }
  }

  Tab _peopleTab() {
    return const Tab(text: 'People');
  }

  Widget _peopleTabView() {
    return Form(
        key: _personFormKey,
        child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int>(
                      value: _personMapping[Person.columnAccountId],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Account Name',
                      ),
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (int? value) {
                        setState(() {
                          _personMapping[Person.columnAccountId] = value;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(i.toString()),
                        );
                      })
                  ),
                ),
              ),
              Row(
                children: [

                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _personMapping['primary_person'],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Primary Person',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _personMapping['primary_person'] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _personMapping['secondary_person'],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Secondary Person',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _personMapping['secondary_person'] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                ]
              ),
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          children: <Widget>[
                            const Text('Skip First Row'),
                            Checkbox(
                                value: _skipFirstRow,
                                onChanged: (value) {
                                  setState(() {
                                    _skipFirstRow = value!;
                                  });
                                }
                            ),
                          ]
                      )
                  ),
                  ElevatedButton(
                      onPressed: () => _importPersons(),
                      child: const Text('Import')
                  ),
                ]
              ),
            ]
        )
    );
  }

  Future<void> _importPersons() async {
    int? accountColumn = _personMapping[Person.columnAccountId];
    int? primaryColumn = _personMapping['primary_person'];
    int? secondaryColumn = _personMapping['secondary_person'];

    if (accountColumn == null) {
      return;
    }

    if (primaryColumn != null) {
      await _importPersonsByColumn(accountColumn, primaryColumn, true);
    }

    if (secondaryColumn != null) {
      await _importPersonsByColumn(accountColumn, secondaryColumn, false);
    }
  }

  Future<void> _importPersonsByColumn(int accountColumn, int nameColumn, bool primary) async {
    for (var row in _data.skip(_skipFirstRow ? 1 : 0)) {
      var accountName = row[accountColumn];
      Account? account = await _accountProvider.selectByName(accountName);

      if (account == null) {
        continue;
      }

      var names = row[nameColumn].toString().trim().split(' ');
      if (names.length != 2) {
        continue;
      }

      Person? person = await _personProvider.selectByFirstAndLastName(account, names.first, names.last);
      if (person == null) {
        await _personProvider.insert(Person.fromMap({
          Person.columnAccountId: account.id,
          Person.columnFirstName: names.first,
          Person.columnLastName: names.last,
          Person.columnMaster: primary
        }));
      }
    }
  }

  Tab _addressTab() {
    return const Tab(text: 'Address');
  }

  Widget _addressTabView() {
    return Form(
        key: _addressFormKey,
        child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int>(
                      value: _addressMapping[Person.columnAccountId],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Account Name',
                      ),
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (int? value) {
                        setState(() {
                          _addressMapping[Person.columnAccountId] = value;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(i.toString()),
                        );
                      })
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<int>(
                        value: _addressMapping[Address.columnLine1],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Line 1',
                        ),
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        onChanged: (int? value) {
                          setState(() {
                            _addressMapping[Address.columnLine1] = value;
                          });
                        },
                        items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                          return DropdownMenuItem<int>(
                            value: i,
                            child: Text(i.toString()),
                          );
                        })
                    )
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<int>(
                        value: _addressMapping[Address.columnLine2],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Line 2',
                        ),
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        onChanged: (int? value) {
                          setState(() {
                            _addressMapping[Address.columnLine2] = value;
                          });
                        },
                        items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                          return DropdownMenuItem<int>(
                            value: i,
                            child: Text(i.toString()),
                          );
                        })
                    )
                ),
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _addressMapping[Address.columnCity],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'City',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _addressMapping[Address.columnCity] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _addressMapping[Address.columnState],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'State',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _addressMapping[Address.columnState] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _addressMapping[Address.columnPostalCode],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Postal Code',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _addressMapping[Address.columnPostalCode] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                ]
              ),
              Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            children: <Widget>[
                              const Text('Skip First Row'),
                              Checkbox(
                                  value: _skipFirstRow,
                                  onChanged: (value) {
                                    setState(() {
                                      _skipFirstRow = value!;
                                    });
                                  }
                              ),
                            ]
                        )
                    ),
                    ElevatedButton(
                        onPressed: () => _importAddress(),
                        child: const Text('Import')
                    ),
                  ]
              ),
            ]
        )
    );
  }

  Future<void> _importAddress() async {
    int? accountColumn = _addressMapping[Address.columnAccountId];
    int? line1Column = _addressMapping[Address.columnLine1];
    int? line2Column = _addressMapping[Address.columnLine2];
    int? cityColumn = _addressMapping[Address.columnCity];
    int? stateColumn = _addressMapping[Address.columnState];
    int? postalCodeColumn = _addressMapping[Address.columnPostalCode];

    if (accountColumn == null) {
      return;
    }

    for (var row in _data.skip(_skipFirstRow ? 1 : 0)) {
      var accountName = row[accountColumn];
      Account? account = await _accountProvider.selectByName(accountName);

      if (account == null) {
        continue;
      }

      String line1 = line1Column == null ? '' : row[line1Column];
      String line2 = line2Column == null ? '' : row[line2Column];
      String city = cityColumn == null ? '' : row[cityColumn];
      String state = stateColumn == null ? '' : row[stateColumn];
      String postalCode = postalCodeColumn == null ? '' : row[postalCodeColumn].toString();

      Address? address = await _addressProvider.loadByAccount(account);
      if (address == null) {
        await _addressProvider.insert(Address.fromMap({
          Address.columnAccountId: account.id,
          Address.columnLine1: line1,
          Address.columnLine2: line2,
          Address.columnCity: city,
          Address.columnState: state,
          Address.columnPostalCode: postalCode,
        }));
      } else {
        address.line1 = line1;
        address.line2 = line2;
        address.city = city;
        address.state = state;
        address.postalCode = postalCode;

        await _addressProvider.update(address);
      }
    }
  }

  Tab _categoryTab() {
    return const Tab(text: 'Category');
  }

  Widget _categoryTabView() {
    return Form(
        key: _categoryFormKey,
        child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int>(
                      value: _categoryMapping[Category.columnName],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 20,
                      elevation: 12,
                      onChanged: (int? value) {
                        setState(() {
                          _categoryMapping[Category.columnName] = value;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(i.toString()),
                        );
                      })
                  ),

                ),
              ),
              Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            children: <Widget>[
                              const Text('Skip First Row'),
                              Checkbox(
                                  value: _skipFirstRow,
                                  onChanged: (value) {
                                    setState(() {
                                      _skipFirstRow = value!;
                                    });
                                  }
                              ),
                            ]
                        )
                    ),
                    ElevatedButton(
                        onPressed: () => _importCategories(),
                        child: const Text('Import')
                    ),
                  ]
              ),
            ]
        )
    );
  }

  Future<void> _importCategories() async {
    for (var row in _data.skip(_skipFirstRow ? 1 : 0)) {
      var name = row[_categoryMapping[Category.columnName]!];
      Category? category = await _categoryProvider.selectByName(name);

      category ??= await _categoryProvider.insert(Category.fromMap({
        Category.columnName: name,
        Category.columnActive: true,
      }));
    }
  }

  Tab _donationTab() {
    return const Tab(text: 'Donation');
  }

  Widget _donationTabView() {
    return Form(
        key: _donationFormKey,
        child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int>(
                      value: _donationMapping[Donation.columnAccountId],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Account Name',
                      ),
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (int? value) {
                        setState(() {
                          _donationMapping[Donation.columnAccountId] = value;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(i.toString()),
                        );
                      })
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _donationMapping[Donation.columnReceived],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Received Date',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _donationMapping[Donation.columnReceived] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _donationMapping[Donation.columnDate],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Item Date',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _donationMapping[Donation.columnDate] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                ]
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _donationMapping[Donation.columnCheck],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Check Number',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _donationMapping[Donation.columnCheck] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _donationMapping[Donation.columnACH],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'ACH',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _donationMapping[Donation.columnACH] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<int>(
                            value: _donationMapping[Donation.columnACHTrace],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'ACH Trace',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (int? value) {
                              setState(() {
                                _donationMapping[Donation.columnACHTrace] = value;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(i.toString()),
                              );
                            })
                        )
                    ),
                  ),
                ]
              ),
              Row(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<int>(
                              value: _donationMapping[Donation.columnAmount],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Amount',
                              ),
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              onChanged: (int? value) {
                                setState(() {
                                  _donationMapping[Donation.columnAmount] = value;
                                });
                              },
                              items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                                return DropdownMenuItem<int>(
                                  value: i,
                                  child: Text(i.toString()),
                                );
                              })
                          )
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<int>(
                              value: _donationMapping[Donation.columnCategoryId],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Category',
                              ),
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              onChanged: (int? value) {
                                setState(() {
                                  _donationMapping[Donation.columnCategoryId] = value;
                                });
                              },
                              items: List<DropdownMenuItem<int>>.generate(_data.isEmpty ? 0 : _data.first.length, (i) {
                                return DropdownMenuItem<int>(
                                  value: i,
                                  child: Text(i.toString()),
                                );
                              })
                          )
                      ),
                    ),
                  ]
              ),
              Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            children: <Widget>[
                              const Text('Skip First Row'),
                              Checkbox(
                                  value: _skipFirstRow,
                                  onChanged: (value) {
                                    setState(() {
                                      _skipFirstRow = value!;
                                    });
                                  }
                              ),
                            ]
                        )
                    ),
                    ElevatedButton(
                        onPressed: () => _importDonation(),
                        child: const Text('Import')
                    ),
                  ]
              ),
            ]
        )
    );
  }

  Future<void> _importDonation() async {
    int? accountColumn = _donationMapping[Donation.columnAccountId];
    int? categoryColumn = _donationMapping[Donation.columnCategoryId];

    int? receivedDateColumn = _donationMapping[Donation.columnReceived];
    int? itemDateColumn = _donationMapping[Donation.columnDate];
    int? checkNumberColumn = _donationMapping[Donation.columnCheck];
    int? achAccountColumn = _donationMapping[Donation.columnACH];
    int? achTraceColumn = _donationMapping[Donation.columnACHTrace];
    int? amountColumn = _donationMapping[Donation.columnAmount];

    if (accountColumn == null) {
      return;
    }

    if (categoryColumn == null) {
      return;
    }

    for (var row in _data.skip(_skipFirstRow ? 1 : 0)) {
      var accountName = row[accountColumn];
      Account? account = await _accountProvider.selectByName(accountName);

      if (account == null) {
        continue;
      }

      var categoryName = row[categoryColumn];
      Category? category = await _categoryProvider.selectByName(categoryName);

      if (category == null) {
        continue;
      }

      String receivedDate = receivedDateColumn == null ? '' : row[receivedDateColumn].toString();
      String itemDate = itemDateColumn == null ? '' : row[itemDateColumn].toString();
      String checkNumber = checkNumberColumn == null ? '' : row[checkNumberColumn].toString();
      String achAccount = achAccountColumn == null ? '' : row[achAccountColumn].toString();
      String achTrace = achTraceColumn == null ? '' : row[achTraceColumn].toString();
      String amount = amountColumn == null ? '0.0' : row[amountColumn].toString();

      await _donationProvider.insert(Donation.fromMap({
        Donation.columnAccountId: account.id,
        Donation.columnReceived: receivedDate,
        Donation.columnDate: itemDate,
        Donation.columnCheck: checkNumber,
        Donation.columnACH: achAccount,
        Donation.columnACHTrace: achTrace,
        Donation.columnAmount: amount,
        Donation.columnCategoryId: category.id,
      }));
    }
  }

  Widget _dataTable() {
    if (_data.isEmpty) {
      return const Text('Load data');
    } else {
      return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: _dataColumns(),
            rows: _dataRows(),
          )
      );
    }
  }

  List<DataColumn> _dataColumns() {
    if (_data.isEmpty) {
      return <DataColumn>[];
    } else {
      return List<DataColumn>.generate(_data.first.length, (i) {
        return DataColumn(
            label: Text(i.toString(),
              textAlign: TextAlign.center,
            )
        );
      });
    }
  }

  List<DataRow> _dataRows() {
    return List<DataRow>.generate(
        _data.length > 3 ? 3 : _data.length, (index) =>
        DataRow(
            cells: _data[index].map((e) {
              return DataCell(Text(e.toString()));
            }).toList()
        )
    );
  }
}
