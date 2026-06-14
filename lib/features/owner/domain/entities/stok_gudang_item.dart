enum StokGudangStatus { aman, rendah, habis }

class StokGudangItem {
  const StokGudangItem({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.unitProduk,
    required this.qtyStok,
    required this.qtyTahan,
    this.imageUrl,
  });

  final String id;
  final String nama;
  final String kategori;
  final String unitProduk;
  final int qtyStok;
  final int qtyTahan;
  final String? imageUrl;

  StokGudangStatus get status {
    if (qtyStok <= 0) return StokGudangStatus.habis;
    if (qtyStok < qtyTahan) return StokGudangStatus.rendah;
    return StokGudangStatus.aman;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StokGudangItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
