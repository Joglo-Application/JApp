import 'package:flutter/material.dart';

import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

/// State for the category feature.
///
/// Rules:
/// - Only talks to [CategoryRepository] (domain contract).
/// - Never imports Hive, datasources, or widgets.
/// - UI reads state via [categories], [isLoading], [errorMessage].
class CategoryProvider extends ChangeNotifier {
  CategoryProvider({required CategoryRepository repository})
    : _repository = repository;

  final CategoryRepository _repository;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Public state ────────────────────────────────────────────────────────────
  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─── Actions ─────────────────────────────────────────────────────────────────

  /// Loads all categories from the repository.
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _repository.getCategories();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a new category with the given [name] and optional fields.
  Future<void> addCategory({
    required String name,
    String? description,
    int? iconCode,
    int? colorValue,
  }) async {
    final category = Category(
      id: IdGenerator.generate(),
      name: name,
      description: description,
      iconCode: iconCode,
      colorValue: colorValue,
    );
    try {
      await _repository.addCategory(category);
      _categories = [..._categories, category];
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add category: $e';
      notifyListeners();
    }
  }

  /// Updates an existing category.
  Future<void> updateCategory(Category category) async {
    try {
      await _repository.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories = List.from(_categories)..[index] = category;
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
      notifyListeners();
    }
  }

  /// Deletes the category identified by [id].
  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      _categories = _categories.where((c) => c.id != id).toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      notifyListeners();
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
