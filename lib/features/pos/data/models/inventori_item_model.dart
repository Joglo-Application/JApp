import '../../domain/entities/inventori_item.dart';

class InventoriItemModel {
  const InventoriItemModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.qtyStok,
    required this.qtyTahan,
    this.imageUrl,
  });

  factory InventoriItemModel.fromJson(Map<String, dynamic> json) {
    return InventoriItemModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      kategori: json['kategori'] as String,
      qtyStok: (json['qtyStok'] as num).toInt(),
      qtyTahan: (json['qtyTahan'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  final String id;
  final String nama;
  final String kategori;
  final int qtyStok;
  final int qtyTahan;
  final String? imageUrl;

  InventoriItem toEntity() => InventoriItem(
        id: id,
        nama: nama,
        kategori: kategori,
        qtyStok: qtyStok,
        qtyTahan: qtyTahan,
        imageUrl: imageUrl,
      );
}
