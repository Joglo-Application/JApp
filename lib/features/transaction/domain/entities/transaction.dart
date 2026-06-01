/// Pure domain entity for a completed transaction.
class Transaction {
  const Transaction({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.paymentMethod = 'Cash',
    this.note,
  });

  final String id;
  final List<TransactionItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final double taxAmount;
  final double discountAmount;
  final String paymentMethod;
  final String? note;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  String toString() =>
      'Transaction(id: $id, total: $totalAmount, items: ${items.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Transaction && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A single line item inside a [Transaction].
class TransactionItem {
  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.note,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String? note;

  double get subtotal => unitPrice * quantity;
}
