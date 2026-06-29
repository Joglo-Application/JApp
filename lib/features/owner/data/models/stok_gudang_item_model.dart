import '../../domain/entities/stok_gudang_item.dart';

class StokGudangItemModel {
  const StokGudangItemModel({
    required this.id,
    required this.bahanId,
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
      // Prefer the explicit FK; fall back to parsing the "STK-###" id so this
      // keeps working even if the backend hasn't shipped `bahanId` yet.
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

  StokGudangItem toEntity() => StokGudangItem(
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
