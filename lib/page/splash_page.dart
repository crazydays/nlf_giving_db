import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/page/home_page.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<void> initializeDatabaseProvider(BuildContext context) async {
    context.read<DatabaseProvider>().initialize();
  }

  Future<void> _gotoHomePage() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    initializeDatabaseProvider(context);

    return Consumer<DatabaseProvider>(builder: (context, database, _) {
      if (database.initialized) {
        Future.delayed(const Duration(milliseconds: 50), _gotoHomePage);
      }

      return const Center(
        child: Text('Initializing...'),
      );
    });
  }
}
