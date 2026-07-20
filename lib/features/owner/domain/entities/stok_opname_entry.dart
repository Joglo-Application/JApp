import 'stok_masuk_entry.dart' show ProdukSource;

enum StokOpnameStatus { draft, posted, cancelled }

class StokOpnameProdukItem {
  StokOpnameProdukItem({
    required this.nama,
    required this.qtySystem,
    this.refId = 0,
    this.source = ProdukSource.stokGudang,
    this.qtyAktual = 0,
  });

  /// menuId bila sumbernya inventori, bahanId bila stok gudang.
  final int refId;

  /// Satu dokumen opname boleh memuat bahan baku maupun produk jadi.
  final ProdukSource source;
  final String nama;
  final int qtySystem;
  int qtyAktual;

  int get qtySelisih => qtyAktual - qtySystem;
}

class StokOpnameEntry {
  const StokOpnameEntry({
    required this.kode,
    required this.tanggal,
    required this.createdBy,
    required this.produk,
    required this.status,
    this.catatan,
  });

  final String kode;
  final DateTime tanggal;
  final String createdBy;
  final String? catatan;
  final List<StokOpnameProdukItem> produk;
  final StokOpnameStatus status;
}
