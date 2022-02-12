import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/category.dart';


class CategoryEditPageArguments {
  final Category record;

  CategoryEditPageArguments(this.record);
}

class CategoryEditPage extends StatefulWidget {
  static const route = '/category_edit_page';

  final Category record;

  const CategoryEditPage({ Key? key, required this.record }) : super(key: key);

  @override
  State<CategoryEditPage> createState() => _CategoryEditState();
}

class _CategoryEditState extends State<CategoryEditPage> {
  late TextEditingController _nameController;
  late bool _isActive;

  CategoryProvider get categoryProvider => Provider.of<DatabaseProvider>(context, listen: false).categoryProvider;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.record.name);
    _isActive = widget.record.active == true;
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
        title: const Text('Edit Category'),
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
                                _update();
                                Navigator.pop(context);
                              },
                              child: const Text('Update')
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

  void _update() async {
    Category record = Category.fromMap({
      Category.columnId: widget.record.id,
      Category.columnName: _nameController.value.text,
      Category.columnActive: _isActive
    });

    await categoryProvider.update(record);
  }
}
