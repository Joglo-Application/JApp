import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/stok_dokumen_remote_datasource.dart';
import '../../domain/entities/kategori_stok.dart';
import '../../domain/entities/produksi_stok_entry.dart';
import '../../domain/entities/stok_keluar_entry.dart';
import '../../domain/entities/stok_masuk_entry.dart';
import '../../domain/entities/stok_opname_entry.dart';

class KelolaStokProvider extends ChangeNotifier {
  KelolaStokProvider({StokDokumenRemoteDatasource? datasource})
      : _datasource = datasource ?? StokDokumenRemoteDatasource() {
    loadStokMasuk();
    loadStokKeluar();
  }

  final StokDokumenRemoteDatasource _datasource;

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
  int _produksiCounter = 0;
  int _opnameCounter = 0;
  int _kategoriCounter = 5;

  List<StokMasukEntry> get stokMasukList => List.unmodifiable(_stokMasukList);
  List<StokKeluarEntry> get stokKeluarList => List.unmodifiable(_stokKeluarList);
  List<ProduksiStokEntry> get produksiStokList => List.unmodifiable(_produksiStokList);
  List<StokOpnameEntry> get stokOpnameList => List.unmodifiable(_stokOpnameList);
  List<KategoriStok> get kategoriStokList => List.unmodifiable(_kategoriStokList);

  /// Kode dokumen kini ditentukan server saat penyimpanan, jadi belum bisa
  /// diketahui saat form dibuka. Menampilkan tebakan lokal hanya akan
  /// berbeda dari yang benar-benar tersimpan.
  String generateKodeMasuk() => '(otomatis)';

  /// Sama seperti stok masuk: kode ditentukan server saat penyimpanan.
  String generateKodeKeluar() => '(otomatis)';

  String generateKodeProduksi() {
    _produksiCounter++;
    return 'PS-${_produksiCounter.toString().padLeft(3, '0')}';
  }

  String generateKodeOpname() {
    _opnameCounter++;
    return 'SO-${_opnameCounter.toString().padLeft(3, '0')}';
  }

  /// Memuat daftar dokumen stok masuk dari server.
  Future<void> loadStokMasuk() async {
    try {
      final rows = await _datasource.fetchStokMasuk();
      _stokMasukList
        ..clear()
        ..addAll(rows.map(_toStokMasukEntry));
      notifyListeners();
    } on ApiException {
      // Biarkan daftar apa adanya; layar menampilkan kosong daripada palsu.
    }
  }

  static StokMasukStatus _statusMasuk(String s) => switch (s) {
        'posted' => StokMasukStatus.posted,
        'cancelled' => StokMasukStatus.cancelled,
        _ => StokMasukStatus.draft,
      };

  static StokMasukEntry _toStokMasukEntry(DokumenStok d) => StokMasukEntry(
        kode: d.kode,
        tanggal: d.tanggal,
        createdBy: d.createdBy,
        supplier: d.supplier,
        catatan: d.catatan,
        status: _statusMasuk(d.status),
        produk: d.produk
            .map((p) => StokMasukProdukItem(
                  refId: ((p['menuId'] ?? p['bahanId']) as num?)?.toInt() ?? 0,
                  nama: (p['nama'] ?? '').toString(),
                  source: p['sumber'] == 'inventori'
                      ? ProdukSource.inventori
                      : ProdukSource.stokGudang,
                  jumlah: (p['jumlah'] as num?)?.toInt() ?? 1,
                ))
            .toList(),
      );

  /// Menyimpan dokumen stok masuk ke server lalu memuat ulang daftarnya.
  /// Mengembalikan pesan galat bila gagal, atau `null` bila berhasil.
  Future<String?> addStokMasuk(StokMasukEntry entry) async {
    try {
      await _datasource.createStokMasuk(
        items: entry.produk
            .map((p) => ItemDokumen(refId: p.refId, jumlah: p.jumlah))
            .toList(),
        sumber: entry.produk
            .map((p) =>
                p.source == ProdukSource.inventori ? 'inventori' : 'stok_gudang')
            .toList(),
        supplier: entry.supplier,
        catatan: entry.catatan,
        langsungPosting: entry.status == StokMasukStatus.posted,
      );
    } on ApiException catch (e) {
      return e.message;
    }
    await loadStokMasuk();
    return null;
  }

  void updateStokMasuk(StokMasukEntry entry) {
    final i = _stokMasukList.indexWhere((e) => e.kode == entry.kode);
    if (i != -1) {
      _stokMasukList[i] = entry;
      notifyListeners();
    }
  }

  /// Memuat daftar dokumen stok keluar dari server.
  Future<void> loadStokKeluar() async {
    try {
      final rows = await _datasource.fetchStokKeluar();
      _stokKeluarList
        ..clear()
        ..addAll(rows.map(_toStokKeluarEntry));
      notifyListeners();
    } on ApiException {
      // Biarkan daftar apa adanya.
    }
  }

  static StokKeluarStatus _statusKeluar(String s) => switch (s) {
        'posted' => StokKeluarStatus.posted,
        'cancelled' => StokKeluarStatus.cancelled,
        _ => StokKeluarStatus.draft,
      };

  static StokKeluarEntry _toStokKeluarEntry(DokumenStok d) => StokKeluarEntry(
        kode: d.kode,
        tanggal: d.tanggal,
        createdBy: d.createdBy,
        catatan: d.catatan,
        status: _statusKeluar(d.status),
        produk: d.produk
            .map((p) => StokKeluarProdukItem(
                  refId: ((p['menuId'] ?? p['bahanId']) as num?)?.toInt() ?? 0,
                  nama: (p['nama'] ?? '').toString(),
                  harga: (p['harga'] as num?)?.toInt() ?? 0,
                  jumlah: (p['jumlah'] as num?)?.toInt() ?? 1,
                ))
            .toList(),
      );

  /// Menyimpan dokumen stok keluar ke server lalu memuat ulang daftarnya.
  /// Mengembalikan pesan galat bila gagal, atau `null` bila berhasil.
  Future<String?> addStokKeluar(StokKeluarEntry entry) async {
    try {
      await _datasource.createStokKeluar(
        items: entry.produk
            .map((p) =>
                ItemDokumen(refId: p.refId, jumlah: p.jumlah, harga: p.harga))
            .toList(),
        catatan: entry.catatan,
        langsungPosting: entry.status == StokKeluarStatus.posted,
      );
    } on ApiException catch (e) {
      return e.message;
    }
    await loadStokKeluar();
    return null;
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
