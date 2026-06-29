import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../domain/entities/supplier_item.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/usecases/fetch_supplier_items_usecase.dart';

class SupplierProvider extends ChangeNotifier {
  SupplierProvider({SupplierRepository? repository})
      : _repo = repository ?? SupplierRepositoryImpl() {
    _fetchItems = FetchSupplierItemsUseCase(_repo);
  }

  final SupplierRepository _repo;
  late final FetchSupplierItemsUseCase _fetchItems;

  bool _isLoading = false;
  String? _error;
  List<SupplierItem> _all = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SupplierItem> get items => _all;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _fetchItems();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat data. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah bahan baku baru (POST /bahan-baku) lalu muat ulang daftar.
  /// Mengembalikan `false` bila gagal (pesan di [error]).
  Future<bool> createItem({
    required String namaBahan,
    required String satuan,
    required num stok,
    required num stokMinimum,
    String? kategori,
  }) =>
      _runWrite(() => _repo.createItem(
            namaBahan: namaBahan,
            satuan: satuan,
            stok: stok,
            stokMinimum: stokMinimum,
            kategori: kategori,
          ));

  /// Ubah bahan baku (PATCH /bahan-baku/:id) lalu muat ulang.
  Future<bool> updateStok(
    int bahanId, {
    String? namaBahan,
    String? satuan,
    num? stok,
    num? stokMinimum,
    String? kategori,
  }) =>
      _runWrite(() => _repo.updateItem(
            bahanId,
            namaBahan: namaBahan,
            satuan: satuan,
            stok: stok,
            stokMinimum: stokMinimum,
            kategori: kategori,
          ));

  /// Tambah stok (PATCH /bahan-baku/:id/tambah-stok) lalu muat ulang.
  Future<bool> tambahStok(int bahanId, num jumlah) =>
      _runWrite(() => _repo.tambahStok(bahanId, jumlah));

  /// Hapus bahan baku (DELETE /bahan-baku/:id) lalu muat ulang.
  Future<bool> deleteItem(int bahanId) =>
      _runWrite(() => _repo.deleteItem(bahanId));

  /// Menjalankan operasi tulis lalu refresh daftar dari server.
  Future<bool> _runWrite(Future<void> Function() action) async {
    _error = null;
    try {
      await action();
      await load();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Operasi gagal. Coba lagi.';
      notifyListeners();
      return false;
    }
  }
}
