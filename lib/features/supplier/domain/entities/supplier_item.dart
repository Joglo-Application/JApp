enum SupplierItemStatus { aman, rendah, habis }

class SupplierItem {
  const SupplierItem({
    required this.id,
    required this.bahanId,
    required this.nama,
    required this.kategori,
    required this.unitProduk,
    required this.qtyStok,
    required this.qtyTahan,
    this.imageUrl,
  });

  final String id;
  final int bahanId;
  final String nama;
  final String kategori;
  final String unitProduk;
  final int qtyStok;
  final int qtyTahan;
  final String? imageUrl;

  SupplierItemStatus get status {
    if (qtyStok <= 0) return SupplierItemStatus.habis;
    if (qtyStok < qtyTahan) return SupplierItemStatus.rendah;
    return SupplierItemStatus.aman;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SupplierItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
