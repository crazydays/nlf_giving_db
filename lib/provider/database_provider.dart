import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:nlf_giving_db/db/giving_database.dart';
import 'package:nlf_giving_db/db/account.dart';
import 'package:nlf_giving_db/db/address.dart';
import 'package:nlf_giving_db/db/category.dart';
import 'package:nlf_giving_db/db/donation.dart';
import 'package:nlf_giving_db/db/person.dart';

class DatabaseProvider extends ChangeNotifier {
  static const baseDatabaseFilename = 'zdatabase';
  static final databaseFile = File(baseDatabaseFilename).absolute;
  static final databaseFilename = databaseFile.path;
  static final _backupFilenameFormatter = DateFormat("'$databaseFilename'-yyyyMMdd'T'hhmmss'Z'");

  GivingDatabase database = GivingDatabase(databaseFilename);
  bool initialized = false;

  AccountProvider get accountProvider => database.getProvider(Account) as AccountProvider;
  AddressProvider get addressProvider => database.getProvider(Address) as AddressProvider;
  CategoryProvider get categoryProvider => database.getProvider(Category) as CategoryProvider;
  DonationProvider get donationProvider => database.getProvider(Donation) as DonationProvider;
  PersonProvider get personProvider => database.getProvider(Person) as PersonProvider;

  Future<void> initialize() async {
    print('DatabaseProvider.initialize');
    await _backupDatabase();

    await database.open();

    accountProvider.dataChangedEvent + (e) => notify(e);
    addressProvider.dataChangedEvent + (e) => notify(e);
    categoryProvider.dataChangedEvent + (e) => notify(e);
    donationProvider.dataChangedEvent + (e) => notify(e);
    personProvider.dataChangedEvent + (e) => notify(e);

    initialized = true;

    notifyListeners();
  }

  Future<void> _backupDatabase() async {
    if (await databaseFile.exists()) {
      await databaseFile.copy(_backupFilenameFormatter.format(DateTime.now()));
    }
  }

  @override
  Future<void> dispose() async {
    accountProvider.dataChangedEvent - (e) => notify(e);
    addressProvider.dataChangedEvent - (e) => notify(e);
    categoryProvider.dataChangedEvent - (e) => notify(e);
    categoryProvider.dataChangedEvent - (e) => notify(e);
    personProvider.dataChangedEvent - (e) => notify(e);

    await database.close();

    super.dispose();
  }

  Future<void> notify(args) async {
    notifyListeners();
  }
}
