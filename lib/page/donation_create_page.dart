import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/account.dart';
import 'package:nlf_giving_db/db/category.dart';
import 'package:nlf_giving_db/db/donation.dart';
import 'package:nlf_giving_db/db/person.dart';


class DonationCreatePage extends StatefulWidget {
  static const route = '/donation_create_page';

  const DonationCreatePage({ Key? key }) : super(key: key);

  @override
  State<DonationCreatePage> createState() => _DonationCreatePageState();
}

class _DonationCreatePageState extends State<DonationCreatePage> {
  static final dateFormat = DateFormat('yyyy-MM-dd');

  DonationProvider get donationProvider => Provider.of<DatabaseProvider>(context, listen: false).donationProvider;
  AccountProvider get accountProvider => Provider.of<DatabaseProvider>(context, listen: false).accountProvider;
  PersonProvider get personProvider => Provider.of<DatabaseProvider>(context, listen: false).personProvider;
  CategoryProvider get categoryProvider => Provider.of<DatabaseProvider>(context, listen: false).categoryProvider;

  final _formKey = GlobalKey<FormState>();

  late DateTime _receivedDate;
  late DateTime _dateDate;

  late TextEditingController _receivedController;
  late TextEditingController _dateController;
  late TextEditingController _checkController;
  late TextEditingController _achController;
  late TextEditingController _achTraceController;
  late TextEditingController _amountController;

  int? _accountId;
  Category? _category;

  @override
  void initState() {
    super.initState();

    _receivedController = TextEditingController();
    _dateController = TextEditingController();
    _checkController = TextEditingController();
    _achController = TextEditingController();
    _achTraceController = TextEditingController();
    _amountController = TextEditingController();

    _updateReceivedDate(DateTime.now());
    _updateDateDate(DateTime.now());
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _dateController.dispose();
    _checkController.dispose();
    _achController.dispose();
    _achTraceController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  Future<List<_AccountSearchItem>> _filterAccountSearchItems(String? filter) async {
    List<Account> accounts = await accountProvider.filter(filter);
    List<Person> people = await personProvider.filter(filter);

    List<_AccountSearchItem> accountItems = accounts.map(
            (account) => _AccountSearchItem(account.id!, account.name!)
    ).toList();

    List<_AccountSearchItem> peopleItems = people.map(
            (person) => _AccountSearchItem(person.accountId!, '${person.firstName} ${person.lastName}')
    ).toList();

    return accountItems + peopleItems;
  }

  void _updateReceivedDate(DateTime? date) {
    if (date == null) {
      setState(() {
        _receivedDate = DateTime.now();
      });
    } else {
      setState(() {
        _receivedDate = date;
      });
    }

    _receivedController.text = dateFormat.format(_receivedDate);
  }

  void _updateDateDate(DateTime? date) {
    if (date == null) {
      setState(() {
        _dateDate = DateTime.now();
      });
    } else {
      setState(() {
        _dateDate = date;
      });
    }

    _dateController.text = dateFormat.format(_dateDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Donation'),
      ),
      body: Card(
          margin: const EdgeInsets.all(10.0),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DropdownSearch<_AccountSearchItem>(
                          validator: (v) => v == null ? "Account required" : null,
                          mode: Mode.MENU,
                          dropdownSearchDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Account',
                          ),
                          showAsSuffixIcons: true,
                          showSearchBox: true,
                          showClearButton: true,
                          onFind: (filter) => _filterAccountSearchItems(filter),
                          itemAsString: (_AccountSearchItem? item) => item!.value,
                          onChanged: (value) {
                            setState(() {
                              _accountId = value!.accountId;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _receivedController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Received Date',
                          ),
                          onTap: () async {
                            var date = await showDatePicker(
                                context: context,
                                initialDate: _receivedDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            _updateReceivedDate(date);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Date',
                          ),
                          onTap: () async {
                            var date = await showDatePicker(
                                context: context,
                                initialDate: _receivedDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            _updateDateDate(date);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _checkController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Check Number',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: _achController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ACH Account',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _achTraceController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ACH Trace',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Amount',
                          ),
                          validator: (v) => v == null || double.tryParse(v) == null ? 'Amount required' : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DropdownSearch<Category>(
                          validator: (v) => v == null ? "Category required" : null,
                          mode: Mode.MENU,
                          dropdownSearchDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Category',
                          ),
                          showAsSuffixIcons: true,
                          showSearchBox: true,
                          showClearButton: true,
                          onFind: (filter) => categoryProvider.activeByFilter(filter),
                          itemAsString: (Category? category) => category!.name!,
                          onChanged: (value) {
                            setState(() {
                              _category = value;
                            });
                          },
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
                                    if (_formKey.currentState!.validate()) {
                                      _create();
                                    }
                                  },
                                  child: const Text('Add')
                              ),
                            ],
                          )
                      ),
                    ],
                  )
              )
          )
      ),
    );
  }

  Future<void> _create() async {
    Donation record = Donation.fromMap({
      Donation.columnAccountId: _accountId,
      Donation.columnReceived: _receivedDate,
      Donation.columnDate: _dateDate,
      Donation.columnCheck: _checkController.value.text,
      Donation.columnACH: _achController.value.text,
      Donation.columnACHTrace: _achTraceController.value.text,
      Donation.columnAmount: _amountController.value.text,
      Donation.columnCategoryId: _category!.id,
    });

    await donationProvider.insert(record);
  }
}

class _AccountSearchItem {
  final int accountId;
  final String value;

  _AccountSearchItem(this.accountId, this.value);
}