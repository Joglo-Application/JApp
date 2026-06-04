import '../../domain/entities/product.dart';

/// Wire model for a row from `GET /menus`.
///
/// Mirrors the backend `menus` table shape and maps it onto the domain
/// [Product] the UI already speaks.
class MenuModel {
  const MenuModel({
    required this.menuId,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    required this.isActive,
  });

  final int menuId;
  final String namaMenu;
  final String kategori;
  final int harga;
  final bool isActive;

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuId: (json['menuId'] as num).toInt(),
      namaMenu: (json['namaMenu'] ?? '').toString(),
      kategori: (json['kategori'] ?? '').toString(),
      harga: (json['harga'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// The API has no image yet, so [Product.imageUrl] stays null and the card
  /// falls back to its placeholder icon. `isActive` drives availability.
  Product toProduct() => Product(
        id: menuId.toString(),
        name: namaMenu,
        price: harga.toDouble(),
        categoryId: kategori,
        isAvailable: isActive,
      );
}
