import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'provider.dart';

import 'category.dart';
import 'account.dart';
import 'person.dart';
import 'address.dart';
import 'donation.dart';

class GivingDatabase {

  final Map<Type, Provider> providers = {};
  final String filename;
  late Database database;

  GivingDatabase(this.filename);

  void _setupProviders() {
    print('giving_database setting up providers');
    providers[Category] = CategoryProvider(database);
    providers[Account] = AccountProvider(database);
    providers[Person] = PersonProvider(database);
    providers[Address] = AddressProvider(database);
    providers[Donation] = DonationProvider(database);
    print('giving_database setup providers');
  }

  Provider getProvider(Type type) {
    return providers[type]!;
  }

  void onCreate(Database database, int version) async {
    await Category.onCreate(database, version);
    await Account.onCreate(database, version);
    await Person.onCreate(database, version);
    await Address.onCreate(database, version);
    await Donation.onCreate(database, version);
  }

  Future<void> open() async {
    print('giving_database open');
    database = await openDatabase(filename, version: 1, onCreate: onCreate);
    print('giving_database opened');
    _setupProviders();
    return Future(() {});
  }

  Future<void> close() async {
    return database.close();
  }
}
