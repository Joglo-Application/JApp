class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;

  double get subtotal => unitPrice * quantity;

  OrderItem copyWith({int? quantity}) => OrderItem(
        productId: productId,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem && other.productId == productId;

  @override
  int get hashCode => productId.hashCode;
}
