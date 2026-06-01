import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

/// Hive-persisted model for [Category].
///
/// Responsibility: serialization / deserialization only.
/// Converting between [CategoryModel] and [Category] keeps the domain pure.
@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.iconCode,
    this.colorValue,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int? iconCode;

  @HiveField(4)
  int? colorValue;

  // ─── Mapping ────────────────────────────────────────────────────────────────

  /// Creates a [CategoryModel] from the pure domain [Category].
  factory CategoryModel.fromEntity(Category entity) => CategoryModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        iconCode: entity.iconCode,
        colorValue: entity.colorValue,
      );

  /// Converts this model back to the pure domain [Category].
  Category toEntity() => Category(
        id: id,
        name: name,
        description: description,
        iconCode: iconCode,
        colorValue: colorValue,
      );
}
