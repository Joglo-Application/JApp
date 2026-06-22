enum StokOpnameStatus { draft, posted, cancelled }

class StokOpnameProdukItem {
  StokOpnameProdukItem({
    required this.nama,
    required this.qtySystem,
    this.qtyAktual = 0,
  });

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
