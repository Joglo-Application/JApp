import '../../domain/entities/stok_gudang_item.dart';

class StokGudangItemModel {
  const StokGudangItemModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.unitProduk,
    required this.qtyStok,
    required this.qtyTahan,
    this.imageUrl,
  });

  factory StokGudangItemModel.fromJson(Map<String, dynamic> json) {
    return StokGudangItemModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      kategori: json['kategori'] as String,
      unitProduk: json['unitProduk'] as String,
      qtyStok: (json['qtyStok'] as num).toInt(),
      qtyTahan: (json['qtyTahan'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  final String id;
  final String nama;
  final String kategori;
  final String unitProduk;
  final int qtyStok;
  final int qtyTahan;
  final String? imageUrl;

  StokGudangItem toEntity() => StokGudangItem(
        id: id,
        nama: nama,
        kategori: kategori,
        unitProduk: unitProduk,
        qtyStok: qtyStok,
        qtyTahan: qtyTahan,
        imageUrl: imageUrl,
      );
}
