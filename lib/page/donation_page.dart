import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../db/giving_database.dart';
import '../db/account.dart';
import '../db/category.dart';
import '../db/donation.dart';
import 'donation_create_page.dart';
import 'donation_edit_page.dart';

class DonationArguments {
  final GivingDatabase database;

  DonationArguments(this.database);
}

class DonationPage extends StatefulWidget {
  static const String route = '/donation';

  final GivingDatabase database;

  const DonationPage({ Key? key, required this.database }) : super(key: key);

  @override
  State<DonationPage> createState() => _DonationState();
}

class _DonationState extends State<DonationPage> {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  final _filterFormKey = GlobalKey<FormState>();
  late TextEditingController _accountNameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  DateTime? _startDate;
  DateTime? _endDate;
  Category? _category;


  late DonationProvider _provider;
  late CategoryProvider _categoryProvider;

  late List<Map<String, Object?>> _donations;

  @override
  void initState() {
    super.initState();

    _accountNameController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    _provider = widget.database.getProvider(Donation) as DonationProvider;
    _provider.dataChangedEvent + (e) => _loadDonations();
    _donations = [];

    _categoryProvider = widget.database.getProvider(Category) as CategoryProvider;

    _loadDonations();
  }

  @override
  void dispose() {
    _provider.dataChangedEvent - (e) => _loadDonations();
    super.dispose();
  }

  void _popupFilters(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Filter'),
            content: Container(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _filterFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: _accountNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: _startDateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Start Date',
                        ),
                        onTap: () async {
                          var date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));
                          _updateStartDate(date);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: _endDateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'End Date',
                        ),
                        onTap: () async {
                          var date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));
                          _updateEndDate(date);
                        },
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
                                  _clearFilter();
                                  Navigator.pop(context);
                                },
                                child: const Text('Clear')
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  _applyFilter();
                                  Navigator.pop(context);
                                },
                                child: const Text('Apply')
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _updateStartDate(DateTime? date) {
    print('_updateStartDate: $date');
    _startDate = date;
  }

  void _updateEndDate(DateTime? date) {
    print('_updateEndDate: $date');
    _endDate = date;
  }

  Future<void> _applyFilter() async {
    _loadDonations();
  }

  Future<void> _clearFilter() async {
    _accountNameController.text = '';
    _startDateController.text = '';
    _endDateController.text = '';
    _startDate = null;
    _endDate = null;
    _category = null;

    _loadDonations();
  }

  Future<void> _loadDonations() async {
    List<Map<String, Object?>> donations = await _provider.filter(
        _accountNameController.text, _startDate, _endDate, _category);
    setState(() {
      _donations = donations;
    });
  }

  Future<void> _delete(Donation record) async {
    _provider.delete(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _popupFilters(context),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (index) {
              switch (index) {
                case 'filter':
                  print('Filter');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  child: Text('Filter'),
                  value: 'filter'
              ),
            ],
          ),
        ],
      ),
      body: Card(
          margin: const EdgeInsets.all(10.0),
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                            label: Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                            label: Text('Received', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataColumn(
                            label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataColumn(
                            label: Text('Check #', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataColumn(
                            label: Text('ACH', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataColumn(
                            label: Text('ACH Trace', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataColumn(
                            label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataColumn(
                            label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataColumn(
                            label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                      ],
                      rows: List<DataRow>.generate(
                          _donations.length,
                              (int index) => DataRow(
                              cells: <DataCell>[
                                DataCell(
                                    Text(_donations[index]['${Account.table}_${Account.columnName}']! as String)
                                ),
                                DataCell(
                                    Text(_donations[index][Donation.columnReceived] as String)
                                ),
                                DataCell(
                                    Text(_donations[index][Donation.columnDate] as String)
                                ),
                                DataCell(
                                    Text(_donations[index][Donation.columnCheck]! as String)
                                ),
                                DataCell(
                                    Text(_donations[index][Donation.columnACH]! as String)
                                ),
                                DataCell(
                                    Text(_donations[index][Donation.columnACHTrace]! as String)
                                ),
                                DataCell(
                                    Text(Donation.currencyFormat.format((_donations[index][Donation.columnAmount] as int) / 100.0)),
                                ),
                                DataCell(
                                    Text(_donations[index]['${Category.table}_${Category.columnName}']! as String)
                                ),
                                DataCell(
                                    Row(
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context,
                                                  DonationEditPage.route,
                                                  arguments: DonationEditPageArguments(widget.database, Donation.fromMap(_donations[index]))
                                              );
                                            },
                                            icon: const Icon(Icons.edit)
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              _delete(Donation.fromMap(_donations[index]));
                                            },
                                            icon: const Icon(Icons.delete)
                                        ),
                                      ],
                                    )
                                ),
                              ]
                          )
                      )
                  )
              )
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
              context,
              DonationCreatePage.route,
              arguments: DonationCreatePageArguments(widget.database)
          );
        },
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }
}
