/// Pure domain entity representing a product category.
///
/// No Hive, Flutter, or Provider imports — domain is framework-free.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.description,
    this.iconCode,
    this.colorValue,
  });

  final String id;
  final String name;
  final String? description;
  final int? iconCode;    // MaterialIcons codepoint
  final int? colorValue;  // Color.value integer

  Category copyWith({
    String? id,
    String? name,
    String? description,
    int? iconCode,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  String toString() => 'Category(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
