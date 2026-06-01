import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

/// Hive-persisted model for [Product].
///
/// Responsibility: serialization / deserialization only.
@HiveType(typeId: 1)
class ProductModel extends HiveObject {
  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.description,
    this.imageUrl,
    this.stock,
    this.isAvailable = true,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  String? description;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  int? stock;

  @HiveField(7)
  bool isAvailable;

  // ─── Mapping ────────────────────────────────────────────────────────────────

  /// Creates a [ProductModel] from the pure domain [Product].
  factory ProductModel.fromEntity(Product entity) => ProductModel(
        id: entity.id,
        name: entity.name,
        price: entity.price,
        categoryId: entity.categoryId,
        description: entity.description,
        imageUrl: entity.imageUrl,
        stock: entity.stock,
        isAvailable: entity.isAvailable,
      );

  /// Converts this model back to the pure domain [Product].
  Product toEntity() => Product(
        id: id,
        name: name,
        price: price,
        categoryId: categoryId,
        description: description,
        imageUrl: imageUrl,
        stock: stock,
        isAvailable: isAvailable,
      );
}
