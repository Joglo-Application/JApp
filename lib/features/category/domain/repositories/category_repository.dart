import '../entities/category.dart';

/// Contract that any category data source must fulfill.
///
/// Switching from Hive to REST API only requires changing the *implementation*,
/// never this interface or anything that depends on it (Provider, UI).
abstract class CategoryRepository {
  /// Returns all stored categories.
  Future<List<Category>> getCategories();

  /// Persists a new [category].
  Future<void> addCategory(Category category);

  /// Updates an existing [category] by its [Category.id].
  Future<void> updateCategory(Category category);

  /// Permanently removes the category identified by [id].
  Future<void> deleteCategory(String id);
}
