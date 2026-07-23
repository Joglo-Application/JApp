import '../entities/supplier_item.dart';

abstract class SupplierRepository {
  Future<List<SupplierItem>> fetchItems();
  Future<void> createItem({
    required String namaBahan,
    required String satuan,
    required num stok,
    required num stokMinimum,
    String? kategori,
    String? imageUrl,
  });

  Future<String> uploadFoto({
    required List<int> bytes,
    required String namaFile,
  });
  Future<void> updateItem(
    int bahanId, {
    String? namaBahan,
    String? satuan,
    num? stok,
    num? stokMinimum,
    String? kategori,
    String? imageUrl,
  });
  Future<void> tambahStok(int bahanId, num jumlah);
  Future<void> deleteItem(int bahanId);
}
