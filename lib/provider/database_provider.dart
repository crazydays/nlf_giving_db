import 'package:flutter/material.dart';

import 'package:nlf_giving_db/db/giving_database.dart';
import 'package:nlf_giving_db/db/account.dart';
import 'package:nlf_giving_db/db/address.dart';
import 'package:nlf_giving_db/db/category.dart';
import 'package:nlf_giving_db/db/donation.dart';
import 'package:nlf_giving_db/db/person.dart';

class DatabaseProvider extends ChangeNotifier {
  GivingDatabase database = GivingDatabase('zdatabase');
  bool initialized = false;

  AccountProvider get accountProvider => database.getProvider(Account) as AccountProvider;
  AddressProvider get addressProvider => database.getProvider(Address) as AddressProvider;
  CategoryProvider get categoryProvider => database.getProvider(Category) as CategoryProvider;
  DonationProvider get donationProvider => database.getProvider(Donation) as DonationProvider;
  PersonProvider get personProvider => database.getProvider(Person) as PersonProvider;

  Future<void> initialize() async {
    // TODO: add backup database step

    await database.open();

    accountProvider.dataChangedEvent.subscribe((args) => notify(args));
    addressProvider.dataChangedEvent.subscribe((args) => notify(args));
    categoryProvider.dataChangedEvent.subscribe((args) => notify(args));
    donationProvider.dataChangedEvent.subscribe((args) => notify(args));
    personProvider.dataChangedEvent.subscribe((args) => notify(args));

    initialized = true;

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    accountProvider.dataChangedEvent.unsubscribe((args) => notify(args));
    addressProvider.dataChangedEvent.unsubscribe((args) => notify(args));
    categoryProvider.dataChangedEvent.unsubscribe((args) => notify(args));
    categoryProvider.dataChangedEvent.unsubscribe((args) => notify(args));
    personProvider.dataChangedEvent.unsubscribe((args) => notify(args));

    await database.close();

    super.dispose();
  }

  Future<void> notify(args) async {
    notifyListeners();
  }
}
