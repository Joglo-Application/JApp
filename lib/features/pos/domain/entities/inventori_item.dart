enum InventoriStatus { aman, rendah, habis }

class InventoriItem {
  const InventoriItem({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.qtyStok,
    required this.qtyTahan,
    this.imageUrl,
  });

  final String id;
  final String nama;
  final String kategori;
  final int qtyStok;
  final int qtyTahan;
  final String? imageUrl;

  InventoriStatus get status {
    if (qtyStok <= 0) return InventoriStatus.habis;
    if (qtyStok < qtyTahan) return InventoriStatus.rendah;
    return InventoriStatus.aman;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InventoriItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
