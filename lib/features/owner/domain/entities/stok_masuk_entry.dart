enum StokMasukStatus { draft, posted, cancelled }

enum ProdukSource { inventori, stokGudang }

class StokMasukProdukItem {
  StokMasukProdukItem({
    required this.nama,
    required this.source,
    this.jumlah = 1,
  });

  final String nama;
  final ProdukSource source;
  int jumlah;
}

class StokMasukEntry {
  const StokMasukEntry({
    required this.kode,
    required this.tanggal,
    required this.createdBy,
    required this.produk,
    required this.status,
    this.supplier,
    this.catatan,
  });

  final String kode;
  final DateTime tanggal;
  final String createdBy;
  final String? supplier;
  final String? catatan;
  final List<StokMasukProdukItem> produk;
  final StokMasukStatus status;
}
