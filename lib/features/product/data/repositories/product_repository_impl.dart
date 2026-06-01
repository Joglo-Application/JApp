import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';

/// Concrete implementation of [ProductRepository] backed by local Hive storage.
///
/// Future migration pattern:
/// ```dart
/// class ProductRepositoryImpl implements ProductRepository {
///   ProductRepositoryImpl({
///     required this.localDataSource,
///     required this.remoteDataSource,  // add this
///   });
/// }
/// ```
/// Provider and UI remain completely unaffected.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required this.localDataSource});

  final ProductLocalDataSource localDataSource;

  @override
  Future<List<Product>> getProducts() =>
      localDataSource.getProducts();

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) =>
      localDataSource.getProductsByCategory(categoryId);

  @override
  Future<void> addProduct(Product product) =>
      localDataSource.addProduct(product);

  @override
  Future<void> updateProduct(Product product) =>
      localDataSource.updateProduct(product);

  @override
  Future<void> deleteProduct(String id) =>
      localDataSource.deleteProduct(id);
}
