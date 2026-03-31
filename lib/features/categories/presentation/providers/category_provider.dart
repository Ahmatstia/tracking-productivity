import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_os_productivity/features/categories/domain/category_model.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final Box<CategoryModel> _box = Hive.box<CategoryModel>('categories_box');

  CategoryNotifier() : super([]) {
    _loadCategories();
  }

  void _loadCategories() {
    if (_box.isEmpty) {
      _initDefaultCategories();
    } else {
      state = _box.values.toList();
    }
  }

  void _initDefaultCategories() {
    final defaults = [
      CategoryModel(id: 'work', name: 'Kerja', colorCode: 0xFF5B4CDB),
      CategoryModel(id: 'health', name: 'Kesehatan', colorCode: 0xFF00B894),
      CategoryModel(id: 'learning', name: 'Belajar', colorCode: 0xFF007BFF),
      CategoryModel(id: 'personal', name: 'Personal', colorCode: 0xFFE67E22),
    ];

    for (var cat in defaults) {
      _box.put(cat.id, cat);
    }
    state = defaults;
  }

  void addCategory(String name, int colorCode) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newCategory = CategoryModel(id: id, name: name, colorCode: colorCode);
    
    _box.put(id, newCategory);
    state = [...state, newCategory];
  }

  void updateCategory(CategoryModel category) {
    _box.put(category.id, category);
    state = [
      for (final cat in state)
        if (cat.id == category.id) category else cat,
    ];
  }

  void deleteCategory(String id) {
    // We shouldn't delete defaults to avoid breaking old data if we don't handle relations
    // But let's allow it for custom ones
    _box.delete(id);
    state = state.where((cat) => cat.id != id).toList();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return state.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}
