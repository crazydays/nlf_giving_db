import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/account.dart';
import 'package:nlf_giving_db/db/category.dart';
import 'package:nlf_giving_db/db/donation.dart';
import 'package:nlf_giving_db/db/person.dart';


class DonationEditPageArguments {
  final Donation record;

  DonationEditPageArguments(this.record);
}

class DonationEditPage extends StatefulWidget {
  static const route = '/donation_edit_page';

  final Donation record;

  const DonationEditPage({ Key? key, required this.record }) : super(key: key);

  @override
  State<DonationEditPage> createState() => _DonationEditState();
}

class _DonationEditState extends State<DonationEditPage> {
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
  int? _categoryId;

  @override
  void initState() {
    super.initState();

    _receivedDate = widget.record.receivedDate!;
    _dateDate = widget.record.itemDate!;

    _receivedController = TextEditingController(text: dateFormat.format(widget.record.receivedDate!));
    _dateController = TextEditingController(text: dateFormat.format(widget.record.itemDate!));
    _checkController = TextEditingController(text: widget.record.checkNumber ?? '');
    _achController = TextEditingController(text: widget.record.achAccount ?? '');
    _achTraceController = TextEditingController(text: widget.record.achTrace ?? '');
    _amountController = TextEditingController(text: widget.record.amount.toString());
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

  Future<Account?> _loadAccount() {
    return accountProvider.select(widget.record.accountId!);
  }

  Future<Category?> _loadCategory() async {
    return categoryProvider.select(widget.record.categoryId!);
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

  void _updateAccountId(int? accountId) {
    _accountId = accountId ?? widget.record.accountId;
  }

  void _updateCategoryId(int? categoryId) {
    _categoryId = categoryId ?? widget.record.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    // prevent clearing out the value
    _accountId ??= widget.record.accountId;
    _categoryId ??= widget.record.categoryId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Donation'),
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
                        child: FutureBuilder<Account?>(
                          future: _loadAccount(),
                          builder: (BuildContext context, AsyncSnapshot<Account?> snapshot) {
                            _AccountSearchItem accountSearchItem = snapshot.hasData ?
                              _AccountSearchItem(snapshot.data!.id!, snapshot.data!.name!) :
                              _AccountSearchItem(_accountId!, 'Unknown');

                            return DropdownSearch<_AccountSearchItem>(
                              validator: (v) => v == null ? "Account required" : null,
                              mode: Mode.MENU,
                              dropdownSearchDecoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Account',
                              ),
                              showAsSuffixIcons: true,
                              showSearchBox: true,
                              showClearButton: true,
                              selectedItem: accountSearchItem,
                              onFind: (filter) => _filterAccountSearchItems(filter),
                              itemAsString: (_AccountSearchItem? item) => item!.name,
                              onChanged: (value) => _updateAccountId(value?.accountId),
                            );
                          }
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
                        child: FutureBuilder<Category?>(
                          future: _loadCategory(),
                          builder: (BuildContext context, AsyncSnapshot<Category?> snapshot) {
                            Category category = snapshot.hasData ? snapshot.data! : Category.fromMap({
                              Category.columnId: _categoryId!,
                              Category.columnName: 'Unknown'
                            });

                            return DropdownSearch<Category>(
                              validator: (v) => v == null ? "Category required" : null,
                              mode: Mode.MENU,
                              dropdownSearchDecoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Category',
                              ),
                              showAsSuffixIcons: true,
                              showSearchBox: true,
                              showClearButton: true,
                              selectedItem: category,
                              onFind: (filter) => categoryProvider.activeByFilter(filter),
                              itemAsString: (Category? category) => category!.name!,
                              onChanged: (value) => _updateCategoryId(value?.id),
                            );
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
                                      _update();
                                    }
                                  },
                                  child: const Text('Update')
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

  void _update() async {
    Donation record = Donation.fromMap({
      Donation.columnId: widget.record.id,
      Donation.columnAccountId: _accountId,
      Donation.columnReceived: _receivedDate,
      Donation.columnDate: _dateDate,
      Donation.columnCheck: _checkController.value.text,
      Donation.columnACH: _achController.value.text,
      Donation.columnACHTrace: _achTraceController.value.text,
      Donation.columnAmount: _amountController.value.text,
      Donation.columnCategoryId: _categoryId!
    });

    await donationProvider.update(record);
  }
}

class _AccountSearchItem {
  final int accountId;
  final String name;

  _AccountSearchItem(this.accountId, this.name);
}
