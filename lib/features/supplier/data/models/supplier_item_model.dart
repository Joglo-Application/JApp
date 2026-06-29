import '../../domain/entities/supplier_item.dart';

class SupplierItemModel {
  const SupplierItemModel({
    required this.id,
    required this.bahanId,
    required this.nama,
    required this.kategori,
    required this.unitProduk,
    required this.qtyStok,
    required this.qtyTahan,
    this.imageUrl,
  });

  factory SupplierItemModel.fromJson(Map<String, dynamic> json) {
    return SupplierItemModel(
      id: json['id'] as String,
      // FK eksplisit; fallback parse dari "STK-###" bila backend belum kirim.
      bahanId: (json['bahanId'] as num?)?.toInt() ??
          int.tryParse(
                (json['id'] as String? ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
          0,
      nama: json['nama'] as String,
      kategori: json['kategori'] as String,
      unitProduk: json['unitProduk'] as String,
      qtyStok: (json['qtyStok'] as num).toInt(),
      qtyTahan: (json['qtyTahan'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  final String id;
  final int bahanId;
  final String nama;
  final String kategori;
  final String unitProduk;
  final int qtyStok;
  final int qtyTahan;
  final String? imageUrl;

  SupplierItem toEntity() => SupplierItem(
        id: id,
        bahanId: bahanId,
        nama: nama,
        kategori: kategori,
        unitProduk: unitProduk,
        qtyStok: qtyStok,
        qtyTahan: qtyTahan,
        imageUrl: imageUrl,
      );
}
