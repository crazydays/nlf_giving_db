import 'package:flutter/material.dart';
import 'category_create_page.dart';
import 'category_edit_page.dart';
import '../db/giving_database.dart';
import '../db/category.dart';

class CategoryPageArguments {
  final GivingDatabase database;

  CategoryPageArguments(this.database);
}

class CategoryPage extends StatefulWidget {
  static const route = '/category_page';

  final GivingDatabase database;

  const CategoryPage({ Key? key, required this.database }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryState();
}

class _CategoryState extends State<CategoryPage> {
  late CategoryProvider _provider;
  late List<Category> _categories;

  @override
  void initState() {
    super.initState();

    _provider = widget.database.getProvider(Category) as CategoryProvider;
    _provider.dataChangedEvent + (e) => _loadCategories();
    _categories = <Category>[];

    _loadCategories();
  }

  void _loadCategories() async {
    _provider.all().asStream().listen((results) {
      setState(() {
        _categories = results.toList();
      });
    });
  }

  void _delete(Category record) {
    _provider.delete(record);
  }

  @override
  void dispose() {
    _provider.dataChangedEvent - (e) => _loadCategories();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Card(
        margin: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))
              ),
              DataColumn(
                label: Text('Active', style: TextStyle(fontWeight: FontWeight.bold))
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))
              ),
            ],
            rows: List<DataRow>.generate(
              _categories.length,
              (int index) => DataRow(
                cells: <DataCell>[
                  DataCell(
                    Text(_categories[index].name!)
                  ),
                  DataCell(
                      Text(_categories[index].active! ? 'Active' : 'Inactive')
                  ),
                  DataCell(
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                CategoryEditPage.route,
                                arguments: CategoryEditPageArguments(widget.database, _categories[index])
                              );
                            },
                            icon: const Icon(Icons.edit)
                          ),
                          IconButton(
                            onPressed: () {
                              _delete(_categories[index]);
                            },
                            icon: const Icon(Icons.delete)
                          ),
                        ],
                      )
                  ),
                ]
              )
            )
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            CategoryCreatePage.route,
            arguments: CategoryCreatePageArguments(widget.database)
          );
        },
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }
}

