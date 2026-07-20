import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/kategori_remote_datasource.dart';
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
    loadStokOpname();
    loadProduksiStok();
    loadKategoriStok();
  }

  final StokDokumenRemoteDatasource _datasource;
  final _kategoriDatasource = KategoriRemoteDatasource();

  final List<StokMasukEntry> _stokMasukList = [];
  final List<StokKeluarEntry> _stokKeluarList = [];
  final List<ProduksiStokEntry> _produksiStokList = [];
  final List<StokOpnameEntry> _stokOpnameList = [];
  final List<KategoriStok> _kategoriStokList = [];

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

  /// Kode ditentukan server saat penyimpanan.
  String generateKodeProduksi() => '(otomatis)';

  /// Kode ditentukan server saat penyimpanan.
  String generateKodeOpname() => '(otomatis)';

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

  /// Memuat daftar dokumen produksi stok dari server.
  Future<void> loadProduksiStok() async {
    try {
      final rows = await _datasource.fetchProduksiStok();
      _produksiStokList
        ..clear()
        ..addAll(rows.map(_toProduksiEntry));
      notifyListeners();
    } on ApiException {
      // Biarkan daftar apa adanya.
    }
  }

  static ProduksiStokStatus _statusProduksi(String s) => switch (s) {
        'posted' => ProduksiStokStatus.posted,
        'cancelled' => ProduksiStokStatus.cancelled,
        _ => ProduksiStokStatus.draft,
      };

  static ProduksiStokEntry _toProduksiEntry(DokumenStok d) => ProduksiStokEntry(
        kode: d.kode,
        tanggal: d.tanggal,
        createdBy: d.createdBy,
        catatan: d.catatan,
        status: _statusProduksi(d.status),
        produk: d.produk
            .map((p) => ProduksiStokProdukItem(
                  refId: (p['menuId'] as num?)?.toInt() ?? 0,
                  nama: (p['nama'] ?? '').toString(),
                  // Rincian resep tidak disimpan pada dokumen; hanya relevan
                  // saat menyusunnya.
                  resep: const [],
                  jumlah: (p['jumlah'] as num?)?.toInt() ?? 1,
                ))
            .toList(),
      );

  /// Menyimpan dokumen produksi stok ke server lalu memuat ulang daftarnya.
  /// Mengembalikan pesan galat bila gagal, atau `null` bila berhasil.
  Future<String?> addProduksiStok(ProduksiStokEntry entry) async {
    try {
      await _datasource.createProduksiStok(
        items: entry.produk
            .map((p) => ItemDokumen(refId: p.refId, jumlah: p.jumlah))
            .toList(),
        catatan: entry.catatan,
        langsungPosting: entry.status == ProduksiStokStatus.posted,
      );
    } on ApiException catch (e) {
      return e.message;
    }
    await loadProduksiStok();
    return null;
  }

  void updateProduksiStok(ProduksiStokEntry entry) {
    final i = _produksiStokList.indexWhere((e) => e.kode == entry.kode);
    if (i != -1) {
      _produksiStokList[i] = entry;
      notifyListeners();
    }
  }

  /// Memuat daftar dokumen stok opname dari server.
  Future<void> loadStokOpname() async {
    try {
      final rows = await _datasource.fetchStokOpname();
      _stokOpnameList
        ..clear()
        ..addAll(rows.map(_toStokOpnameEntry));
      notifyListeners();
    } on ApiException {
      // Biarkan daftar apa adanya.
    }
  }

  static StokOpnameStatus _statusOpname(String s) => switch (s) {
        'posted' => StokOpnameStatus.posted,
        'cancelled' => StokOpnameStatus.cancelled,
        _ => StokOpnameStatus.draft,
      };

  static StokOpnameEntry _toStokOpnameEntry(DokumenStok d) => StokOpnameEntry(
        kode: d.kode,
        tanggal: d.tanggal,
        createdBy: d.createdBy,
        catatan: d.catatan,
        status: _statusOpname(d.status),
        produk: d.produk
            .map((p) => StokOpnameProdukItem(
                  refId: ((p['menuId'] ?? p['bahanId']) as num?)?.toInt() ?? 0,
                  source: p['sumber'] == 'inventori'
                      ? ProdukSource.inventori
                      : ProdukSource.stokGudang,
                  nama: (p['nama'] ?? '').toString(),
                  qtySystem: (p['stokSistem'] as num?)?.round() ?? 0,
                  qtyAktual: (p['stokFisik'] as num?)?.round() ?? 0,
                ))
            .toList(),
      );

  /// Menyimpan dokumen stok opname ke server lalu memuat ulang daftarnya.
  /// Mengembalikan pesan galat bila gagal, atau `null` bila berhasil.
  Future<String?> addStokOpname(StokOpnameEntry entry) async {
    try {
      await _datasource.createStokOpname(
        items: entry.produk
            .map((p) => ItemDokumen(refId: p.refId, jumlah: p.qtyAktual))
            .toList(),
        sumber: entry.produk
            .map((p) =>
                p.source == ProdukSource.inventori ? 'inventori' : 'stok_gudang')
            .toList(),
        stokFisik: entry.produk.map((p) => p.qtyAktual.toDouble()).toList(),
        catatan: entry.catatan,
        langsungPosting: entry.status == StokOpnameStatus.posted,
      );
    } on ApiException catch (e) {
      return e.message;
    }
    await loadStokOpname();
    return null;
  }

  void updateStokOpname(StokOpnameEntry entry) {
    final i = _stokOpnameList.indexWhere((e) => e.kode == entry.kode);
    if (i != -1) {
      _stokOpnameList[i] = entry;
      notifyListeners();
    }
  }

  /// Id kategori kini ditentukan server; nilai ini hanya penanda sementara
  /// untuk entri yang belum tersimpan.
  String generateKategoriId() => '';

  /// Memuat kategori stok dari server.
  Future<void> loadKategoriStok() async {
    try {
      final rows = await _kategoriDatasource.fetch('stok');
      _kategoriStokList
        ..clear()
        ..addAll(rows.map((k) => KategoriStok(
              id: k.kategoriId.toString(),
              nama: k.nama,
            )));
      notifyListeners();
    } on ApiException {
      // Biarkan daftar apa adanya.
    }
  }

  Future<void> addKategoriStok(KategoriStok entry) async {
    try {
      await _kategoriDatasource.create(
        jenis: 'stok',
        nama: entry.nama,
        urutan: _kategoriStokList.length,
      );
    } on ApiException {
      return;
    }
    await loadKategoriStok();
  }

  Future<void> updateKategoriStok(KategoriStok updated) async {
    final id = int.tryParse(updated.id);
    if (id == null) return;
    try {
      await _kategoriDatasource.update(id, nama: updated.nama);
    } on ApiException {
      return;
    }
    await loadKategoriStok();
  }

  Future<void> removeKategoriStok(String id) async {
    final numId = int.tryParse(id);
    if (numId == null) return;
    try {
      await _kategoriDatasource.delete(numId);
    } on ApiException {
      return;
    }
    await loadKategoriStok();
  }

  /// Menyusun ulang urutan kategori. Urutan baru disimpan ke server supaya
  /// tetap sama saat layar dibuka lagi.
  Future<void> reorderKategoriStok(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _kategoriStokList.removeAt(oldIndex);
    _kategoriStokList.insert(newIndex, item);
    notifyListeners();

    for (var i = 0; i < _kategoriStokList.length; i++) {
      final id = int.tryParse(_kategoriStokList[i].id);
      if (id == null) continue;
      try {
        await _kategoriDatasource.update(id, urutan: i);
      } on ApiException {
        return;
      }
    }
  }
}
