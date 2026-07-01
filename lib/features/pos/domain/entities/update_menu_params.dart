import 'menu_resep_input.dart';

/// Everything sent in `PATCH /menus/{id}` to edit an existing product. Stok
/// and stokMinimum are intentionally absent — inventory quantities are not
/// editable from this form (tracked separately).
class UpdateMenuParams {
  const UpdateMenuParams({
    required this.id,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    this.isActive = true,
    this.resep = const [],
    this.royaltyPoint,
    this.isProdukKhusus = false,
    this.produkKhususMulai,
    this.produkKhususSelesai,
    this.catatan,
  });

  final String id;
  final String namaMenu;
  final String kategori;
  final int harga;
  final bool isActive;
  final List<MenuResepInput> resep;

  /// Optional loyalty points earned per purchase.
  final int? royaltyPoint;

  /// When true, [produkKhususMulai] and [produkKhususSelesai] must be set.
  final bool isProdukKhusus;

  /// `YYYY-MM-DD` date strings (the API stores them as dates).
  final String? produkKhususMulai;
  final String? produkKhususSelesai;
  final String? catatan;
}
