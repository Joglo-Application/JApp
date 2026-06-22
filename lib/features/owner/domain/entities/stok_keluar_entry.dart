enum StokKeluarStatus { draft, posted, cancelled }

class StokKeluarProdukItem {
  StokKeluarProdukItem({
    required this.nama,
    required this.harga,
    this.jumlah = 1,
  });

  final String nama;
  final int harga;
  int jumlah;
}

class StokKeluarEntry {
  const StokKeluarEntry({
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
  final List<StokKeluarProdukItem> produk;
  final StokKeluarStatus status;
}
