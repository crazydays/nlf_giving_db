import 'dart:async';
import 'package:sqflite/sqflite.dart';

class GivingDatabase {
  final String filename;

  GivingDatabase(this.filename);

  void onCreate() {

  }

  Future<Database> database() async {
    return openDatabase(this.filename);
  }


}
