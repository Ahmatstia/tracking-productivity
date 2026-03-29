import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 11)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorCode;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorCode,
  });
}
