import 'menu_resep_input.dart';

/// Everything sent in `POST /menus` to create a product. Optional fields are
/// omitted from the request when unset.
class CreateMenuParams {
  const CreateMenuParams({
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    this.isActive = true,
    this.stok = 0,
    this.stokMinimum = 0,
    this.resep = const [],
    this.royaltyPoint,
    this.isProdukKhusus = false,
    this.produkKhususMulai,
    this.produkKhususSelesai,
    this.catatan,
  });

  final String namaMenu;
  final String kategori;
  final int harga;
  final bool isActive;
  final int stok;
  final int stokMinimum;
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
