import '../entities/product.dart';

/// Contract that any product data source must fulfill.
///
/// Future migration: add [ProductRemoteDataSource] and update
/// [ProductRepositoryImpl] — this interface remains unchanged.
abstract class ProductRepository {
  /// Returns all stored products.
  Future<List<Product>> getProducts();

  /// Returns products belonging to a specific [categoryId].
  Future<List<Product>> getProductsByCategory(String categoryId);

  /// Persists a new [product].
  Future<void> addProduct(Product product);

  /// Updates an existing [product] by its [Product.id].
  Future<void> updateProduct(Product product);

  /// Permanently removes the product identified by [id].
  Future<void> deleteProduct(String id);
}
