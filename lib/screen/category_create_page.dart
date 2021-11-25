import 'package:flutter/material.dart';
import '../db/giving_database.dart';
import '../db/category.dart';

class CategoryCreatePageArguments {
  final GivingDatabase database;

  CategoryCreatePageArguments(this.database);
}

class CategoryCreatePage extends StatefulWidget {
  static const route = '/category_create_page';

  final GivingDatabase database;

  const CategoryCreatePage({ Key? key, required this.database }) : super(key: key);

  @override
  State<CategoryCreatePage> createState() => _CategoryCreateState();
}

class _CategoryCreateState extends State<CategoryCreatePage> {
  late CategoryProvider _provider;
  late TextEditingController _nameController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Category) as CategoryProvider;
    _nameController = TextEditingController();
    _isActive = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Category'),
      ),
      body: Card(
        margin: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      const Text('Active'),
                      Checkbox(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value!;
                          });
                        }
                      ),
                    ]
                  )
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')
                      ),
                      ElevatedButton(
                          onPressed: () {
                            _create();
                            Navigator.pop(context);
                          },
                          child: const Text('Create')
                      ),
                    ],
                  )
                ),
              ],
            )
        )
      ),
    );
  }

  void _create() async {
    Category record = Category.fromMap({
      Category.columnName: _nameController.value.text,
      Category.columnActive: _isActive
    });

    await _provider.insert(record);
  }
}
