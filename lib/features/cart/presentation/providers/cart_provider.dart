import 'package:flutter/foundation.dart';
import '../../domain/entities/cart_item.dart';
import '../../../product/domain/entities/product.dart';

/// In-memory cart state. No persistence — cart clears on app restart.
///
/// Rules:
/// - Never imports Hive or datasources.
/// - Checkout creates a [Transaction] via [TransactionProvider] (called from UI).
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // ─── Public state ────────────────────────────────────────────────────────────

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  double taxAmount(double taxRate) => subtotal * taxRate;

  double grandTotal(double taxRate) => subtotal + taxAmount(taxRate);

  bool get isEmpty => _items.isEmpty;

  bool containsProduct(String productId) =>
      _items.any((item) => item.product.id == productId);

  int quantityOf(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    return index == -1 ? 0 : _items[index].quantity;
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  /// Adds [product] to the cart. If already present, increments quantity.
  void addProduct(Product product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index == -1) {
      _items.add(CartItem(product: product, quantity: 1));
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    }
    notifyListeners();
  }

  /// Removes one unit of [productId] from the cart. Removes entry if qty = 0.
  void removeProduct(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;

    if (_items[index].quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity - 1,
      );
    }
    notifyListeners();
  }

  /// Completely removes a product line from the cart.
  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  /// Updates the note for a specific cart item.
  void updateNote(String productId, String note) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(note: note.isEmpty ? null : note);
    notifyListeners();
  }

  /// Clears the entire cart — called after a successful checkout.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
