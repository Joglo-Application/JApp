import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../owner/data/datasources/kategori_remote_datasource.dart';
import '../../domain/entities/kategori_stok_gudang.dart';

/// Kategori stok gudang tersimpan di server (`/kategori` jenis `stok_gudang`),
/// bukan lagi daftar contoh di memori — jadi CRUD gudang benar-benar persist.
class KategoriStokGudangProvider extends ChangeNotifier {
  KategoriStokGudangProvider({KategoriRemoteDatasource? datasource})
      : _ds = datasource ?? KategoriRemoteDatasource();

  final KategoriRemoteDatasource _ds;
  static const _jenis = 'stok_gudang';

  final List<KategoriStokGudang> _list = [];
  String? _error;
  bool _isLoading = false;

  List<KategoriStokGudang> get list => List.unmodifiable(_list);
  String? get error => _error;
  bool get isLoading => _isLoading;

  /// Muat kategori dari server.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rows = await _ds.fetch(_jenis);
      _list
        ..clear()
        ..addAll(rows.map((k) => KategoriStokGudang(
              id: k.kategoriId.toString(),
              nama: k.nama,
              produkCount: k.produkCount,
            )));
    } on ApiException {
      // Biarkan daftar apa adanya bila gagal memuat.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah kategori baru; mengembalikan `false` bila gagal ([error] berisi pesan).
  Future<bool> addKategori(String nama) async {
    _error = null;
    try {
      await _ds.create(jenis: _jenis, nama: nama, urutan: _list.length);
      await load();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateKategori(KategoriStokGudang updated) async {
    final id = int.tryParse(updated.id);
    if (id == null) return false;
    _error = null;
    try {
      await _ds.update(id, nama: updated.nama);
      await load();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeKategori(String id) async {
    final numId = int.tryParse(id);
    if (numId == null) return false;
    _error = null;
    try {
      await _ds.delete(numId);
      await load();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Susun ulang urutan lalu simpan ke server.
  Future<void> reorderKategori(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _list.removeAt(oldIndex);
    _list.insert(newIndex, item);
    notifyListeners();
    for (var i = 0; i < _list.length; i++) {
      final id = int.tryParse(_list[i].id);
      if (id == null) continue;
      try {
        await _ds.update(id, urutan: i);
      } on ApiException {
        // Abaikan kegagalan satu baris; urutan tetap tampil sesuai layar.
      }
    }
  }
}
