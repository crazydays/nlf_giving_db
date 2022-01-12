import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../db/giving_database.dart';
import '../db/category.dart';
import '../db/account.dart';
import '../db/person.dart';
import '../db/address.dart';
import '../db/donation.dart';

class TaxReportGenerator {
  final int _donationsFirstPage = 28;
  final int _donationsPerPage = 60;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormat = NumberFormat.simpleCurrency();

  final GivingDatabase _database;
  final Account _account;
  final int _year;

  late PersonProvider _personProvider;
  late AddressProvider _addressProvider;
  late DonationProvider _donationProvider;
  late CategoryProvider _categoryProvider;

  late List<Category> _categories;
  late List<Donation> _donations;
  late bool _hasChecks;
  late bool _hasAchs;
  late double _total;

  late ByteData _logoImage;

  TaxReportGenerator(this._database, this._account, this._year) {
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
    List<Person> persons = await _selectPersons();
    Address? address = await _selectAddress();
    _donations = await _selectDonations();
    _hasChecks = _testHasChecks();
    _hasAchs = _testHasAchs();
    _total = _calculateTotal();

    _logoImage = await rootBundle.load('assets/images/new-life-logo.png');

    await generatePdf(persons, address);
  }

  Future<List<Person>> _selectPersons() async {
    return _personProvider.allForAccount(_account);
  }

  Future<Address?> _selectAddress() async {
    return _addressProvider.loadByAccount(_account);
  }

  Future<List<Donation>> _selectDonations() async {
    return _donationProvider.byAccountByYear(_account, _year);
  }

  bool _testHasChecks() {
    return _donations.where((d) {
      return d.checkNumber == null ? false : d.checkNumber!.isNotEmpty;
    }).isNotEmpty;
  }

  bool _testHasAchs() {
    return _donations.where((d) {
      return (d.achAccount == null ? false : d.achAccount!.isNotEmpty) || (d.achTrace == null ? false : d.achTrace!.isNotEmpty);
    }).isNotEmpty;
  }

  double _calculateTotal() {
    return _donations.fold(0.0, (a, d) => a + d.amount!);
  }

  Future<void> generatePdf(List<Person> persons, Address? address) async {
    List<Donation> donations = _donationsForPage(0);

    var pdf = pw.Document();
    pdf.addPage(
        pw.Page(
            build: (pw.Context context) => pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: _headerWidgets() +
                    _verticalPadding() +
                    _addresseeWidgets(persons, address) +
                    _verticalPadding() +
                    _body() +
                    _verticalPadding() +
                    _donationsTableWidgets(donations,
                        totalRow: true,
                        continued: (_donations.length > _donationsFirstPage)) +
                    _verticalPadding() +
                    _taxRegulationNotice()
            )
        )
    );

    if (_donations.length > _donationsFirstPage) {
      for (int i = 1; ; i++) {
        List<Donation> donations = _donationsForPage(i);

        if (donations.isEmpty) {
          break;
        }

        pdf.addPage(
            pw.Page(
                build: (pw.Context context) => pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: _donationsTableWidgets(donations, totalRow: false)
                )
            )
        );
      }
    }

    final file = File('./${_account.name}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  List<Donation> _donationsForPage(int page) {
    if (page == 0) {
      return _donations.take(_donationsFirstPage).toList();
    } else {
      return _donations.skip(_donationsFirstPage + ((page - 1) * _donationsPerPage)).take(_donationsPerPage).toList();
    }
  }

  List<pw.Widget> _verticalPadding({ double height = 24.0 }) {
    return <pw.Widget>[
      pw.Container(height: height)
    ];
  }

  List<pw.Widget> _headerWidgets() {
    List<pw.Widget> widgets = [];

    widgets.add(pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(pw.MemoryImage(_logoImage.buffer.asUint8List()), height: 48, width: 122)
                      ]
                  ),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('New Life Fellowship'),
                        pw.Text('12960 James St'),
                        pw.Text('Holland, MI 49424'),
                      ]
                  ),
                ]
            ),
          ]
      )
    ));

    return widgets;
  }

  List<pw.Widget> _addresseeWidgets(List<Person> persons, Address? address) {
    List<pw.Widget> widgets = [];

    widgets.add(
        pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: _personsWidgets(persons) + _addressWidgets(address)
            )
        )
    );

    return widgets;
  }

  List<pw.Widget> _personsWidgets(List<Person> persons) {
    List<pw.Widget> widgets = [];

    for (Person person in persons) {
      widgets.add(pw.Text('${person.firstName} ${person.lastName}'));
    }

    return widgets;
  }

  List<pw.Widget> _addressWidgets(Address? address) {
    List<pw.Widget> widgets = [];

    if (address != null && address.line1 != null && address.line1!.isNotEmpty) {
      widgets.add(pw.Text(address.line1!));
      if (address.line2 != null && address.line2!.isNotEmpty) {
        widgets.add(pw.Text(address.line2!));
      }
      widgets.add(pw.Text('${address.city}, ${address.state} ${address.postalCode}'));
    }

    return widgets;
  }

  List<pw.Widget> _body() {
    return <pw.Widget>[
      pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Dear ${_account.name},', textAlign: pw.TextAlign.left),
              pw.Container(height: 12.0),
              pw.Text('Thank you for supporting the ministries of New Life Fellowship.  We have included a detailed list of your donations in $_year.  Your total gifts during this time is ${_currencyFormat.format(_total)}.', textAlign: pw.TextAlign.left),
            ]
        ),
      )
    ];
  }

  List<pw.Widget> _donationsTableWidgets(List<Donation> donations, {
    required bool totalRow,
    bool continued = false,
  }) {
    List<pw.Widget> widgets = [];

    widgets.add(pw.Table(
        children: _donationRows(donations, totalRow: totalRow)
    ));

    if (continued) {
      widgets.add(pw.Text('Additional transaction listed on subsequent pages.', textScaleFactor: 0.80));
    }

    return widgets;
  }

  List<pw.TableRow> _donationRows(List<Donation> donations, { required bool totalRow, }) {
    List<pw.TableRow> rows = [];
    rows.add(_tableHeaderRow());
    rows.addAll(donations.map((donation) => _donationRow(donation)).toList());
    if (totalRow) {
      rows.add(_totalRow());
    }
    return rows;
  }

  pw.TableRow _tableHeaderRow() {
    return pw.TableRow(
        children: _headerRowColumns()
    );
  }

  List<pw.Widget> _headerRowColumns() {
    List<pw.Widget> columns = [];

    columns.add(
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: pw.Text('Item Date', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        )
    );

    if (_hasChecks) {
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text('Check No', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          )
      );
    }

    if (_hasAchs) {
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text('ACH', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          )
      );
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text('Trace', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          )
      );
    }

    columns.add(
        pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text('Category', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
        )
    );

    columns.add(
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: pw.Text('Amount', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        )
    );

    return columns;
  }

  pw.TableRow _donationRow(Donation donation) {
    return pw.TableRow(
        children: _donationRowColumns(donation)
    );
  }

  List<pw.Widget> _donationRowColumns(Donation donation) {
    List<pw.Widget> columns = [];

    columns.add(
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: pw.Text(_dateFormat.format(donation.itemDate!), textAlign: pw.TextAlign.left),
        )
    );

    if (_hasChecks) {
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text(donation.checkNumber ?? '', textAlign: pw.TextAlign.right),
          )
      );
    }

    if (_hasAchs) {
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text(donation.achAccount ?? '', textAlign: pw.TextAlign.right),
          )
      );
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text(donation.achTrace ?? '', textAlign: pw.TextAlign.right),
          )
      );
    }

    columns.add(
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: pw.Text(_findCategory(donation.categoryId!).name!, textAlign: pw.TextAlign.left),
        )
    );

    columns.add(
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: pw.Text(_currencyFormat.format(donation.amount), textAlign: pw.TextAlign.right),
        )
    );

    return columns;
  }

  pw.TableRow _totalRow() {
    return pw.TableRow(
        children: _totalRowColumns()
    );
  }

  List<pw.Widget> _totalRowColumns() {
    List<pw.Widget> columns = [];

    columns.add(
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: pw.Text('Total', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        )
    );

    if (_hasChecks) {
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text('', textAlign: pw.TextAlign.right),
          )
      );
    }

    if (_hasAchs) {
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text('', textAlign: pw.TextAlign.right),
          )
      );
      columns.add(
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: pw.Text('', textAlign: pw.TextAlign.right),
          )
      );
    }

    columns.add(
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: pw.Text('', textAlign: pw.TextAlign.left),
        )
    );

    columns.add(
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: pw.Text(_currencyFormat.format(_total), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        )
    );

    return columns;
  }

  Category _findCategory(int id) {
    return _categories.where((category) => category.id == id).first;
  }

  List<pw.Widget> _taxRegulationNotice() {
    return <pw.Widget>[
      pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: pw.Text('Per IRS Regulations, we hereby state that no goods or services were received in exchange for this donation. New Life Fellowship is a 501(C)3 corporation. Our tax id is 38-3345758.')
      )
    ];
  }
}
