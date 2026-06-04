class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final double price;
  final String categoryId;
  final String? imageUrl;
  final bool isAvailable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
