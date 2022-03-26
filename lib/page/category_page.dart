import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nlf_giving_db/provider/database_provider.dart';
import 'package:nlf_giving_db/db/category.dart';

import 'package:nlf_giving_db/page/category_create_page.dart';
import 'package:nlf_giving_db/page/category_edit_page.dart';

class CategoryPage extends StatefulWidget {
  static const route = '/category_page';

  const CategoryPage({ Key? key }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryState();
}

class _CategoryState extends State<CategoryPage> {
  CategoryProvider get categoryProvider => Provider.of<DatabaseProvider>(context, listen: false).categoryProvider;

  Future<List<Category>> _load() async {
    return categoryProvider.all();
  }

  void _delete(Category record) {
    categoryProvider.delete(record);
  }

  void _gotoEditCategoryPage(Category category) {
    Navigator.pushNamed(
        context,
        CategoryEditPage.route,
        arguments: CategoryEditPageArguments(category)
    );
  }

  void _gotoCreateCategoryPage() {
    Navigator.pushNamed(
        context,
        CategoryCreatePage.route
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, database, __) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Categories'),
          actions: [
            IconButton(
              onPressed: () => _gotoCreateCategoryPage(),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        body: FutureBuilder<List<Category>>(
            future: _load(),
            builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
              if (snapshot.hasData) {
                return PaginatedDataTable(
                  source: _CategoryDataTableSource(snapshot.data!, _gotoEditCategoryPage, _delete),
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
                  columnSpacing: 100,
                  horizontalMargin: 10,
                  rowsPerPage: _calculateRows(),
                );
              } else {
                return const Text('Loading data...');
              }
            }
        ),

      );
    });
  }

  int _calculateRows() {
    return (MediaQuery.of(context).size.height - 180) ~/ 48;
  }
}

class _CategoryDataTableSource extends DataTableSource {
  final List<Category> _data;
  final Function _edit;
  final Function _delete;

  _CategoryDataTableSource(this._data, this._edit, this._delete);

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(
        cells: [
          DataCell(
              Text(_data[index].name!)
          ),
          DataCell(
              Text(_data[index].active! ? 'Active' : 'Inactive')
          ),
          DataCell(
              Row(
                children: <Widget>[
                  IconButton(
                      onPressed: () => _edit(_data[index]),
                      icon: const Icon(Icons.edit)
                  ),
                  IconButton(
                      onPressed: () => _delete(_data[index]),
                      icon: const Icon(Icons.delete)
                  ),
                ],
              )
          ),
        ]
    );
  }
}

