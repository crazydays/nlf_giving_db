import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../db/giving_database.dart';
import '../db/category.dart';
import '../db/account.dart';
import '../db/person.dart';
import '../db/address.dart';
import '../db/donation.dart';

class TaxReportGenerator {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormat = NumberFormat.simpleCurrency();

  final GivingDatabase _database;
  final Account _account;

  late PersonProvider _personProvider;
  late AddressProvider _addressProvider;
  late DonationProvider _donationProvider;
  late CategoryProvider _categoryProvider;

  late List<Category> _categories;

  TaxReportGenerator(this._database, this._account) {
    _personProvider = _database.providers[Person] as PersonProvider;
    _addressProvider = _database.providers[Address] as AddressProvider;
    _donationProvider = _database.providers[Donation] as DonationProvider;
    _categoryProvider = _database.providers[Category] as CategoryProvider;
  }

  void generate() {
    _generateAccountTaxReport();
  }

  Future<void> _generateAccountTaxReport() async {
    _categories = await _categoryProvider.all();
    List<Person> persons = await _generatePersons();
    Address? address = await _generateAddress();
    List<Donation> donations = await _generateDonations();

    await generatePdf(persons, address, donations);
  }

   Future<List<Person>> _generatePersons() async {
    return _personProvider.allForAccount(_account);
  }

  Future<Address?> _generateAddress() async {
    return _addressProvider.loadByAccount(_account);
  }

  Future<List<Donation>> _generateDonations() async {
    return _donationProvider.byAccount(_account);
  }

  Future<void> generatePdf(List<Person> persons, Address? address, List<Donation> donations) async {
    print('Account: ${_account.name}');

    var pdf = pw.Document();
    pdf.addPage(
        pw.Page(
            build: (pw.Context context) => pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: headerWidgets(persons, address) + bodyWidgets(donations)
            )
        )
    );

    final file = File('./${_account.name}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  List<pw.Widget> headerWidgets(List<Person> persons, Address? address) {
    List<pw.Widget> widgets = [];

    for (var person in persons) {
      widgets.add(pw.Text('${person.firstName} ${person.lastName}'));
    }

    if (address != null) {
      widgets.add(pw.Text(address.line1!));
      if (address.line2 != null && address.line2!.isNotEmpty) {
        widgets.add(pw.Text(address.line2!));
      }
      widgets.add(pw.Text('${address.city}, ${address.state} ${address.postalCode}'));
    }

    return widgets;
  }

  List<pw.Widget> bodyWidgets(List<Donation> donations) {
    List<pw.Widget> widgets = [];

    widgets.add(pw.Table(
      children: donationRows(donations)
    ));

    return widgets;
  }

  List<pw.TableRow> donationRows(List<Donation> donations) {
    List<pw.TableRow> rows = [];
    rows.add(tableHeaderRow());
    rows.addAll(donations.map((donation) => donationRow(donation)).toList());
    return rows;
  }

  pw.TableRow tableHeaderRow() {
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Text('Item Date', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Check No', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('ACH', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Trace', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Amount', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Category', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
        ]
    );
  }

  pw.TableRow donationRow(Donation donation) {
    print('donation: ${donation.id}');
    return pw.TableRow(
      children: <pw.Widget>[
        pw.Text(_dateFormat.format(donation.itemDate!)),
        pw.Text(donation.checkNumber ?? '', textAlign: pw.TextAlign.right),
        pw.Text(donation.achAccount ?? ''),
        pw.Text(donation.achTrace ?? ''),
        pw.Text(_currencyFormat.format(donation.amount), textAlign: pw.TextAlign.right),
        pw.Text(_findCategory(donation.categoryId!).name ?? 'Unknown')
      ]
    );
  }

  Category _findCategory(int id) {
    return _categories.where((category) => category.id == id).first;
  }
}
