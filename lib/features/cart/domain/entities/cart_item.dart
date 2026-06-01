import '../../../product/domain/entities/product.dart';

/// Represents a single item in the shopping cart.
///
/// Cart is in-memory only — no persistence needed between sessions.
class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    this.note,
  });

  final Product product;
  final int quantity;
  final String? note;

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && other.product.id == product.id;

  @override
  int get hashCode => product.id.hashCode;
}
