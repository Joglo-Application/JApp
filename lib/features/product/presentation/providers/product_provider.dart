import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/utils/id_generator.dart';

/// State for the product feature.
///
/// Rules:
/// - Only talks to [ProductRepository] (domain contract).
/// - Never imports Hive, datasources, or widgets.
/// - UI reads state via [products], [isLoading], [errorMessage].
class ProductProvider extends ChangeNotifier {
  ProductProvider({required ProductRepository repository})
      : _repository = repository;

  final ProductRepository _repository;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategoryId;

  // ─── Public state ────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategoryId => _selectedCategoryId;

  /// All products, unfiltered.
  List<Product> get products => List.unmodifiable(_products);

  /// Products filtered by [_selectedCategoryId] (null = show all).
  List<Product> get filteredProducts {
    if (_selectedCategoryId == null) return products;
    return _products
        .where((p) => p.categoryId == _selectedCategoryId)
        .toList();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  /// Loads all products from the repository.
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _products = await _repository.getProducts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Filters the product list to a specific category. Pass `null` to reset.
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// Creates a new product.
  Future<void> addProduct({
    required String name,
    required double price,
    required String categoryId,
    String? description,
    String? imageUrl,
    int? stock,
    bool isAvailable = true,
  }) async {
    final product = Product(
      id: IdGenerator.generate(),
      name: name,
      price: price,
      categoryId: categoryId,
      description: description,
      imageUrl: imageUrl,
      stock: stock,
      isAvailable: isAvailable,
    );
    try {
      await _repository.addProduct(product);
      _products = [..._products, product];
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      notifyListeners();
    }
  }

  /// Updates an existing product.
  Future<void> updateProduct(Product product) async {
    try {
      await _repository.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products = List.from(_products)..[index] = product;
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      notifyListeners();
    }
  }

  /// Deletes the product identified by [id].
  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      _products = _products.where((p) => p.id != id).toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      notifyListeners();
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
