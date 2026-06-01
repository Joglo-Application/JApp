import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

/// The ONLY class that directly accesses Hive for categories.
///
/// Rules:
/// - Widgets, Pages, and Providers must NEVER import this class.
/// - Only [CategoryRepositoryImpl] may depend on this datasource.
/// - To migrate to an API, create [CategoryRemoteDataSource] and update
///   [CategoryRepositoryImpl] — this file stays unchanged.
class CategoryLocalDataSource {
  CategoryLocalDataSource(this._box);

  final Box<CategoryModel> _box;

  /// Returns all categories from the local Hive box.
  Future<List<Category>> getCategories() async {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  /// Stores a new [category]. Uses [category.id] as the Hive key.
  Future<void> addCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _box.put(category.id, model);
  }

  /// Replaces the stored record for [category.id].
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _box.put(category.id, model);
  }

  /// Deletes the record identified by [id].
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }
}
