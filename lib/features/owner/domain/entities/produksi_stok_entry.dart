enum ProduksiStokStatus { draft, posted, cancelled }

class ProduksiStokProdukItem {
  ProduksiStokProdukItem({
    required this.nama,
    required this.resep,
    this.jumlah = 1,
  });

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
