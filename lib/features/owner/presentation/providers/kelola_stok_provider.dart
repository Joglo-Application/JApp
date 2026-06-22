import 'package:flutter/foundation.dart';

import '../../domain/entities/kategori_stok.dart';
import '../../domain/entities/produksi_stok_entry.dart';
import '../../domain/entities/stok_keluar_entry.dart';
import '../../domain/entities/stok_masuk_entry.dart';
import '../../domain/entities/stok_opname_entry.dart';

class KelolaStokProvider extends ChangeNotifier {
  final List<StokMasukEntry> _stokMasukList = [];
  final List<StokKeluarEntry> _stokKeluarList = [];
  final List<ProduksiStokEntry> _produksiStokList = [];
  final List<StokOpnameEntry> _stokOpnameList = [];
  final List<KategoriStok> _kategoriStokList = [
    KategoriStok(id: '1', nama: 'Makanan', produkCount: 2),
    KategoriStok(id: '2', nama: 'Minuman', produkCount: 2),
    KategoriStok(id: '3', nama: 'Snack'),
    KategoriStok(id: '4', nama: 'Kopi'),
    KategoriStok(id: '5', nama: 'Kue'),
  ];
  int _masukCounter = 0;
  int _keluarCounter = 0;
  int _produksiCounter = 0;
  int _opnameCounter = 0;
  int _kategoriCounter = 5;

  List<StokMasukEntry> get stokMasukList => List.unmodifiable(_stokMasukList);
  List<StokKeluarEntry> get stokKeluarList => List.unmodifiable(_stokKeluarList);
  List<ProduksiStokEntry> get produksiStokList => List.unmodifiable(_produksiStokList);
  List<StokOpnameEntry> get stokOpnameList => List.unmodifiable(_stokOpnameList);
  List<KategoriStok> get kategoriStokList => List.unmodifiable(_kategoriStokList);

  String generateKodeMasuk() {
    _masukCounter++;
    return 'SM-${_masukCounter.toString().padLeft(3, '0')}';
  }

  String generateKodeKeluar() {
    _keluarCounter++;
    return 'SK-${_keluarCounter.toString().padLeft(3, '0')}';
  }

  String generateKodeProduksi() {
    _produksiCounter++;
    return 'PS-${_produksiCounter.toString().padLeft(3, '0')}';
  }

  String generateKodeOpname() {
    _opnameCounter++;
    return 'SO-${_opnameCounter.toString().padLeft(3, '0')}';
  }

  void addStokMasuk(StokMasukEntry entry) {
    _stokMasukList.add(entry);
    notifyListeners();
  }

  void updateStokMasuk(StokMasukEntry entry) {
    final i = _stokMasukList.indexWhere((e) => e.kode == entry.kode);
    if (i != -1) {
      _stokMasukList[i] = entry;
      notifyListeners();
    }
  }

  void addStokKeluar(StokKeluarEntry entry) {
    _stokKeluarList.add(entry);
    notifyListeners();
  }

  void updateStokKeluar(StokKeluarEntry entry) {
    final i = _stokKeluarList.indexWhere((e) => e.kode == entry.kode);
    if (i != -1) {
      _stokKeluarList[i] = entry;
      notifyListeners();
    }
  }

  void addProduksiStok(ProduksiStokEntry entry) {
    _produksiStokList.add(entry);
    notifyListeners();
  }

  void updateProduksiStok(ProduksiStokEntry entry) {
    final i = _produksiStokList.indexWhere((e) => e.kode == entry.kode);
    if (i != -1) {
      _produksiStokList[i] = entry;
      notifyListeners();
    }
  }

  void addStokOpname(StokOpnameEntry entry) {
    _stokOpnameList.add(entry);
    notifyListeners();
  }

  void updateStokOpname(StokOpnameEntry entry) {
    final i = _stokOpnameList.indexWhere((e) => e.kode == entry.kode);
    if (i != -1) {
      _stokOpnameList[i] = entry;
      notifyListeners();
    }
  }

  String generateKategoriId() {
    _kategoriCounter++;
    return '$_kategoriCounter';
  }

  void addKategoriStok(KategoriStok entry) {
    _kategoriStokList.add(entry);
    notifyListeners();
  }

  void updateKategoriStok(KategoriStok updated) {
    final i = _kategoriStokList.indexWhere((e) => e.id == updated.id);
    if (i != -1) {
      _kategoriStokList[i] = updated;
      notifyListeners();
    }
  }

  void removeKategoriStok(String id) {
    _kategoriStokList.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void reorderKategoriStok(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _kategoriStokList.removeAt(oldIndex);
    _kategoriStokList.insert(newIndex, item);
    notifyListeners();
  }
}
