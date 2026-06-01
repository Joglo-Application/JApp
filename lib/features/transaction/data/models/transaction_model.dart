import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart' as domain;

part 'transaction_model.g.dart';

// ─── Transaction Item Model ──────────────────────────────────────────────────

@HiveType(typeId: 3)
class TransactionItemModel extends HiveObject {
  TransactionItemModel({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.note,
  });

  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  double unitPrice;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  String? note;

  double get subtotal => unitPrice * quantity;

  factory TransactionItemModel.fromEntity(
          domain.TransactionItem entity) =>
      TransactionItemModel(
        productId: entity.productId,
        productName: entity.productName,
        unitPrice: entity.unitPrice,
        quantity: entity.quantity,
        note: entity.note,
      );

  domain.TransactionItem toEntity() => domain.TransactionItem(
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity,
        note: note,
      );
}

// ─── Transaction Model ───────────────────────────────────────────────────────

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  TransactionModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.paymentMethod = 'Cash',
    this.note,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  List<TransactionItemModel> items;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  double taxAmount;

  @HiveField(5)
  double discountAmount;

  @HiveField(6)
  String paymentMethod;

  @HiveField(7)
  String? note;

  factory TransactionModel.fromEntity(domain.Transaction entity) =>
      TransactionModel(
        id: entity.id,
        items: entity.items
            .map(TransactionItemModel.fromEntity)
            .toList(),
        totalAmount: entity.totalAmount,
        createdAt: entity.createdAt,
        taxAmount: entity.taxAmount,
        discountAmount: entity.discountAmount,
        paymentMethod: entity.paymentMethod,
        note: entity.note,
      );

  domain.Transaction toEntity() => domain.Transaction(
        id: id,
        items: items.map((i) => i.toEntity()).toList(),
        totalAmount: totalAmount,
        createdAt: createdAt,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        paymentMethod: paymentMethod,
        note: note,
      );
}
