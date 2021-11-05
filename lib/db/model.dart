abstract class Model {
  static const String columnId = '_id';

  set id(int? id);
  int? get id;

  Model();

  String getTable();

  Map<String, Object?> toMap();
}