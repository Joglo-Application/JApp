enum DiscountType { amount, percent }

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
    this.discount = 0,
    this.discountType = DiscountType.amount,
    this.note = '',
    this.promoName,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;
  final double discount;
  final DiscountType discountType;
  final String note;
  final String? promoName;

  double get discountAmount {
    if (discount <= 0) return 0;
    if (discountType == DiscountType.percent) {
      return unitPrice * quantity * (discount / 100);
    }
    return discount;
  }

  double get subtotal => (unitPrice * quantity) - discountAmount;

  OrderItem copyWith({
    int? quantity,
    double? discount,
    DiscountType? discountType,
    String? note,
    String? promoName,
  }) =>
      OrderItem(
        productId: productId,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
        discount: discount ?? this.discount,
        discountType: discountType ?? this.discountType,
        note: note ?? this.note,
        promoName: promoName ?? this.promoName,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem && other.productId == productId;

  @override
  int get hashCode => productId.hashCode;
}
