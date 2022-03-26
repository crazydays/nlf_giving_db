import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/account.dart';
import 'package:nlf_giving_db/db/category.dart';
import 'package:nlf_giving_db/db/donation.dart';

import 'donation_create_page.dart';
import 'donation_edit_page.dart';

class DonationPage extends StatefulWidget {
  static const String route = '/donation';

  const DonationPage({ Key? key }) : super(key: key);

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  final _filterFormKey = GlobalKey<FormState>();
  late TextEditingController _accountNameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late _DonationFilter _filter = _DonationFilter();
  late String _filters;

  DonationProvider get donationProvider => Provider.of<DatabaseProvider>(context, listen: false).donationProvider;
  CategoryProvider get categoryProvider => Provider.of<DatabaseProvider>(context, listen: false).categoryProvider;

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _filter = _DonationFilter();
    _filters = _filter.toString();
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _popupFilters(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Filter'),
            content: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _filterFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: _accountNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                        ),
                        onChanged: (value) {
                          _filter._name = value.isEmpty ? null : value;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: _startDateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Start Date',
                        ),
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: _filter._startDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));

                          _filter._startDate = date;
                          _startDateController.text = date == null ? '' : dateFormat.format(date);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: _endDateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'End Date',
                        ),
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: _filter._endDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));
                          _filter._endDate = date;
                          _endDateController.text = date == null ? '' : dateFormat.format(date);
                        },
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
                        selectedItem: _filter._category,
                        onFind: (filter) => categoryProvider.activeByFilter(filter),
                        itemAsString: (Category? category) => category!.name!,
                        onChanged: (value) {
                          _filter._category = value;
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
                                  _filter.clear();
                                  setState(() => _filters = _filter.toString());
                                  Navigator.pop(context);
                                },
                                child: const Text('Clear')
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() => _filters = _filter.toString());
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
        }
    );
  }

  Future<List<Map<String, Object?>>> _load() async {
    return donationProvider.filter(_filter._name, _filter._startDate, _filter._endDate, _filter._category);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, database, __) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Manage Donations: $_filters'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: () => _popupFilters(context),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _gotoCreateDonationPage(),
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, Object?>>>(
          future: _load(),
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, Object?>>> snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: PaginatedDataTable(
                  source: _DonationDataTableSource(snapshot.data!, _gotoEditDonationPage, _delete),
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
                  columnSpacing: 100,
                  horizontalMargin: 10,
                  rowsPerPage: _calculateRows(),
                ),
              );
            } else {
              return const Text('Loading data...');
            }
          },
        ),
      );
    });
  }

  void _gotoCreateDonationPage() {
    Navigator.pushNamed(
        context,
        DonationCreatePage.route
    );
  }

  Future<void> _delete(Donation record) async {
    donationProvider.delete(record);
  }

  void _gotoEditDonationPage(Map<String, Object?> donation) {
    Navigator.pushNamed(
        context,
        DonationEditPage.route,
        arguments: DonationEditPageArguments(Donation.fromMap(donation))
    );
  }

  int _calculateRows() {
    return (MediaQuery.of(context).size.height - 196) ~/ 48;
  }
}

class _DonationDataTableSource extends DataTableSource {
  final List<Map<String, Object?>> _data;
  final Function _edit;
  final Function _delete;

  _DonationDataTableSource(this._data, this._edit, this._delete);

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(
        cells: [
          DataCell(
              Text(_data[index]['${Account.table}_${Account.columnName}']! as String)
          ),
          DataCell(
              Text(_data[index][Donation.columnReceived] as String)
          ),
          DataCell(
              Text(_data[index][Donation.columnDate] as String)
          ),
          DataCell(
              Text(_data[index][Donation.columnCheck]! as String)
          ),
          DataCell(
              Text(_data[index][Donation.columnACH]! as String)
          ),
          DataCell(
              Text(_data[index][Donation.columnACHTrace]! as String)
          ),
          DataCell(
            Text(Donation.currencyFormat.format((_data[index][Donation.columnAmount] as int) / 100.0)),
          ),
          DataCell(
              Text(_data[index]['${Category.table}_${Category.columnName}']! as String)
          ),
          DataCell(
              Row(
                children: [
                  IconButton(
                      onPressed: () => _edit(_data[index]),
                      icon: const Icon(Icons.edit)
                  ),
                  IconButton(
                      onPressed: () => _delete(Donation.fromMap(_data[index])),
                      icon: const Icon(Icons.delete)
                  ),
                ],
              )
          ),
        ]
    );
  }
}

class _DonationFilter {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  String? _name;
  DateTime? _startDate;
  DateTime? _endDate;
  Category? _category;

  void clear() {
    _name = null;
    _startDate = null;
    _endDate = null;
    _category = null;
  }

  @override
  String toString() {
    String accumulator = '';

    if (_name != null) {
      accumulator += ' Name: $_name';
    }

    if (_startDate != null && _endDate != null) {
      accumulator += ' Between: ${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';
    } else if (_startDate != null) {
      accumulator += ' After: ${dateFormat.format(_startDate!)}';
    } else if (_endDate != null) {
      accumulator += ' Before: ${dateFormat.format(_endDate!)}';
    }

    if (_category != null) {
      accumulator += ' Category: ${_category!.name}';
    }

    return accumulator;
  }
}
