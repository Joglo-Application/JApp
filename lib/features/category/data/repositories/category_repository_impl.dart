import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

/// Concrete implementation of [CategoryRepository] backed by local Hive storage.
///
/// Future migration pattern:
/// ```dart
/// class CategoryRepositoryImpl implements CategoryRepository {
///   CategoryRepositoryImpl({
///     required this.localDataSource,
///     required this.remoteDataSource,  // add this
///   });
///   final CategoryLocalDataSource localDataSource;
///   final CategoryRemoteDataSource remoteDataSource; // add this
/// }
/// ```
/// Provider and UI remain completely unaffected.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({required this.localDataSource});

  final CategoryLocalDataSource localDataSource;

  @override
  Future<List<Category>> getCategories() =>
      localDataSource.getCategories();

  @override
  Future<void> addCategory(Category category) =>
      localDataSource.addCategory(category);

  @override
  Future<void> updateCategory(Category category) =>
      localDataSource.updateCategory(category);

  @override
  Future<void> deleteCategory(String id) =>
      localDataSource.deleteCategory(id);
}
