import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../db/giving_database.dart';
import '../db/donation.dart';
import '../db/account.dart';
import '../db/person.dart';
import '../db/category.dart';

class DonationEditPageArguments {
  final GivingDatabase database;
  final Donation record;

  DonationEditPageArguments(this.database, this.record);
}

class DonationEditPage extends StatefulWidget {
  static const route = '/donation_edit_page';

  final GivingDatabase database;
  final Donation record;

  const DonationEditPage({ Key? key, required this.database, required this.record }) : super(key: key);

  @override
  State<DonationEditPage> createState() => _DonationEditState();
}

class _DonationEditState extends State<DonationEditPage> {
  static final dateFormat = DateFormat('yyyy-MM-dd');

  final _formKey = GlobalKey<FormState>();

  late DateTime _receivedDate;
  late DateTime _dateDate;

  late DonationProvider _donationProvider;
  late AccountProvider _accountProvider;
  late PersonProvider _personProvider;
  late CategoryProvider _categoryProvider;

  late TextEditingController _receivedController;
  late TextEditingController _dateController;
  late TextEditingController _checkController;
  late TextEditingController _achController;
  late TextEditingController _achTraceController;
  late TextEditingController _amountController;

  int? _accountId;
  _AccountSearchItem? _accountSearchItem;
  Category? _category;

  @override
  void initState() {
    super.initState();

    _donationProvider = widget.database.getProvider(Donation) as DonationProvider;
    _accountProvider = widget.database.getProvider(Account) as AccountProvider;
    _personProvider = widget.database.getProvider(Person) as PersonProvider;
    _categoryProvider = widget.database.getProvider(Category) as CategoryProvider;

    _receivedDate = widget.record.receivedDate!;
    _dateDate = widget.record.itemDate!;

    _receivedController = TextEditingController(text: dateFormat.format(widget.record.receivedDate!));
    _dateController = TextEditingController(text: dateFormat.format(widget.record.itemDate!));
    _checkController = TextEditingController(text: widget.record.checkNumber ?? '');
    _achController = TextEditingController(text: widget.record.achAccount ?? '');
    _achTraceController = TextEditingController(text: widget.record.achTrace ?? '');
    _amountController = TextEditingController(text: widget.record.amount.toString());

    _loadCategory();
    _loadAccount();
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

  Future<void> _loadCategory() async {
    Category? category = await _categoryProvider.select(widget.record.categoryId!);
    setState(() {
      _category = category;
    });
  }

  Future<void> _loadAccount() async {
    Account? account = await _accountProvider.select(widget.record.accountId!);
    setState(() {
      if (account == null) {
        _accountSearchItem = null;
      } else {
        _accountSearchItem = _AccountSearchItem(account.id!, account.name!);
      }
    });
  }

  Future<List<_AccountSearchItem>> _filterAccountSearchItems(String? filter) async {
    List<Account> accounts = await _accountProvider.filter(filter);
    List<Person> people = await _personProvider.filter(filter);

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

  void _updateAccountId(int accountId) {
    setState(() {
      _accountId = accountId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Donation'),
      ),
      body: Card(
          margin: const EdgeInsets.all(10.0),
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
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
                          selectedItem: _accountSearchItem,
                          onFind: (filter) => _filterAccountSearchItems(filter),
                          itemAsString: (_AccountSearchItem? item) => item!.value,
                          onChanged: (value) {
                            _updateAccountId(value!.accountId);
                          },
                        ),
                      ),
                      Container(
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
                      Container(
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
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _checkController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Check Number',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: _achController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ACH Account',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _achTraceController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ACH Trace',
                          ),
                        ),
                      ),
                      Container(
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
                      Container(
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
                          selectedItem: _category,
                          onFind: (filter) => _categoryProvider.activeByFilter(filter),
                          itemAsString: (Category? category) => category!.name!,
                          onChanged: (value) {
                            setState(() {
                              _category = value;
                            });
                          },
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
      Donation.columnCategoryId: _category!.id,
    });

    await _donationProvider.update(record);
  }
}

class _AccountSearchItem {
  final int accountId;
  final String value;

  _AccountSearchItem(this.accountId, this.value);
}
