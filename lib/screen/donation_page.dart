import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  late DonationProvider _provider;
  late List<Map<String, Object?>> _donations;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Donation) as DonationProvider;
    _provider.dataChangedEvent + (e) => _loadDonations();
    _donations = [];

    _loadDonations();
  }

  @override
  void dispose() {
    _provider.dataChangedEvent - (e) => _loadDonations();
    super.dispose();
  }

  void _loadDonations() async {
    List<Map<String, Object?>> donations = await _provider.all();
    setState(() {
      _donations = donations;
    });
  }

  void _delete(Donation record) async {
    _provider.delete(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Donations'),
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
                            label: Text('Account', style: TextStyle(fontWeight: FontWeight.bold))
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
                                    Text(Donation.currencyFormat.format((_donations[index][Donation.columnAmount] as int) / 100.0))
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

