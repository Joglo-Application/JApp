import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

/// The ONLY class that directly accesses Hive for products.
///
/// Rules:
/// - Widgets, Pages, and Providers must NEVER import this class.
/// - Only [ProductRepositoryImpl] may depend on this datasource.
/// - To migrate to an API, create [ProductRemoteDataSource] and update
///   [ProductRepositoryImpl] — this file stays unchanged.
class ProductLocalDataSource {
  ProductLocalDataSource(this._box);

  final Box<ProductModel> _box;

  /// Returns all products from the local Hive box.
  Future<List<Product>> getProducts() async {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  /// Returns products filtered by [categoryId].
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return _box.values
        .where((model) => model.categoryId == categoryId)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Stores a new [product]. Uses [product.id] as the Hive key.
  Future<void> addProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    await _box.put(product.id, model);
  }

  /// Replaces the stored record for [product.id].
  Future<void> updateProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    await _box.put(product.id, model);
  }

  /// Deletes the record identified by [id].
  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }
}
