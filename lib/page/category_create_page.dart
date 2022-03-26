import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/category.dart';


class CategoryCreatePage extends StatefulWidget {
  static const route = '/category_create_page';

  const CategoryCreatePage({ Key? key }) : super(key: key);

  @override
  State<CategoryCreatePage> createState() => _CategoryCreateState();
}

class _CategoryCreateState extends State<CategoryCreatePage> {

  late TextEditingController _nameController;
  late bool _isActive;

  CategoryProvider get categoryProvider => Provider.of<DatabaseProvider>(context, listen: false).categoryProvider;

  @override
  void initState() {
    super.initState();

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
        child: Padding(
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
                Padding(
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
                Padding(
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

    await categoryProvider.insert(record);
  }
}
