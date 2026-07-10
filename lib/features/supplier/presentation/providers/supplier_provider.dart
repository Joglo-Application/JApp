import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../owner/data/datasources/log_gudang_remote_datasource.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../domain/entities/supplier_item.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/usecases/fetch_supplier_items_usecase.dart';

class SupplierProvider extends ChangeNotifier {
  SupplierProvider({
    SupplierRepository? repository,
    LogGudangRemoteDatasource? logGudang,
  })  : _repo = repository ?? SupplierRepositoryImpl(),
        _logGudang = logGudang ?? LogGudangRemoteDatasourceImpl() {
    _fetchItems = FetchSupplierItemsUseCase(_repo);
  }

  final SupplierRepository _repo;
  final LogGudangRemoteDatasource _logGudang;
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
  }) async {
    final ok = await _runWrite(() => _repo.createItem(
          namaBahan: namaBahan,
          satuan: satuan,
          stok: stok,
          stokMinimum: stokMinimum,
          kategori: kategori,
        ));
    if (ok) _logAksi('ADD_STOK', 'Menambahkan $namaBahan');
    return ok;
  }

  /// Ubah bahan baku (PATCH /bahan-baku/:id) lalu muat ulang.
  Future<bool> updateStok(
    int bahanId, {
    String? namaBahan,
    String? satuan,
    num? stok,
    num? stokMinimum,
    String? kategori,
  }) async {
    final nama = namaBahan ?? _namaOf(bahanId);
    final ok = await _runWrite(() => _repo.updateItem(
          bahanId,
          namaBahan: namaBahan,
          satuan: satuan,
          stok: stok,
          stokMinimum: stokMinimum,
          kategori: kategori,
        ));
    if (ok) _logAksi('UPDATE_ITEM', 'Update $nama');
    return ok;
  }

  /// Tambah stok (PATCH /bahan-baku/:id/tambah-stok) lalu muat ulang.
  Future<bool> tambahStok(int bahanId, num jumlah) async {
    final nama = _namaOf(bahanId);
    final ok = await _runWrite(() => _repo.tambahStok(bahanId, jumlah));
    if (ok) _logAksi('ADD_QTY_STOK', '+$jumlah → $nama');
    return ok;
  }

  /// Hapus bahan baku (DELETE /bahan-baku/:id) lalu muat ulang.
  Future<bool> deleteItem(int bahanId) async {
    final nama = _namaOf(bahanId);
    final ok = await _runWrite(() => _repo.deleteItem(bahanId));
    if (ok) _logAksi('DELETE_ITEM', 'Menghapus $nama');
    return ok;
  }

  String _namaOf(int bahanId) {
    for (final it in _all) {
      if (it.bahanId == bahanId) return it.nama;
    }
    return '';
  }

  /// Catat aksi ke Log Gudang (POST /log-gudang) — fire-and-forget, tak
  /// mengganggu alur bila gagal.
  void _logAksi(String jenis, String logs) {
    unawaited(_logGudang.createLog(jenis: jenis, logs: logs).catchError((_) {}));
  }

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
