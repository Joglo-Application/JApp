enum ProduksiStokStatus { draft, posted, cancelled }

class ProduksiStokProdukItem {
  ProduksiStokProdukItem({
    required this.nama,
    required this.resep,
    this.refId = 0,
    this.jumlah = 1,
  });

  /// menuId produk yang diproduksi.
  final int refId;
  final String nama;
  final List<String> resep;
  int jumlah;
}

class ProduksiStokEntry {
  const ProduksiStokEntry({
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
  final List<ProduksiStokProdukItem> produk;
  final ProduksiStokStatus status;
}
