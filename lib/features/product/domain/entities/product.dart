/// Pure domain entity representing a product.
///
/// No Hive, Flutter, or Provider imports — domain is framework-free.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.description,
    this.imageUrl,
    this.stock,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final double price;
  final String categoryId;
  final String? description;
  final String? imageUrl;
  final int? stock;
  final bool isAvailable;

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? categoryId,
    String? description,
    String? imageUrl,
    int? stock,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
