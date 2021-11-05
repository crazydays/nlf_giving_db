import 'package:flutter/material.dart';
import 'db/giving_database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Life Fellowship Giving Database',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'New Life Fellowship Giving Database'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GivingDatabase database = GivingDatabase('zdatabase');
  bool open = false;

  @override
  void initState() {
    super.initState();

    print('opening database');
    database.open().asStream().listen((event) {
      print('open done');
      _opened();
      print('/open done');
    });
  }

  void _opened() {
    print('opened database');
    setState(() { open = true; });
  }

  @override
  void deactivate() {
    print('closing database');
    database.close().asStream().listen((event) {
      _closed();
    });

    super.deactivate();
  }

  void _closed() {
    print('closed database');
    setState(() { open = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text('database is opened: ${open ? 'true' : 'false'}'),
      ),
    );
  }
}
