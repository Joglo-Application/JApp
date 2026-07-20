import '../../domain/entities/supplier_item.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_datasource.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl({SupplierRemoteDatasource? datasource})
      : _datasource = datasource ?? SupplierRemoteDatasourceImpl();

  final SupplierRemoteDatasource _datasource;

  @override
  Future<List<SupplierItem>> fetchItems() async {
    final models = await _datasource.fetchItems();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createItem({
    required String namaBahan,
    required String satuan,
    required num stok,
    required num stokMinimum,
    String? kategori,
    String? imageUrl,
  }) =>
      _datasource.createItem(
        namaBahan: namaBahan,
        satuan: satuan,
        stok: stok,
        stokMinimum: stokMinimum,
        kategori: kategori,
        imageUrl: imageUrl,
      );

  @override
  Future<void> updateItem(
    int bahanId, {
    String? namaBahan,
    String? satuan,
    num? stok,
    num? stokMinimum,
    String? kategori,
  }) =>
      _datasource.updateItem(
        bahanId,
        namaBahan: namaBahan,
        satuan: satuan,
        stok: stok,
        stokMinimum: stokMinimum,
        kategori: kategori,
      );

  @override
  Future<void> tambahStok(int bahanId, num jumlah) =>
      _datasource.tambahStok(bahanId, jumlah);

  @override
  Future<void> deleteItem(int bahanId) => _datasource.deleteItem(bahanId);

  @override
  Future<String> uploadFoto({
    required List<int> bytes,
    required String namaFile,
  }) =>
      _datasource.uploadFoto(bytes: bytes, namaFile: namaFile);
}
