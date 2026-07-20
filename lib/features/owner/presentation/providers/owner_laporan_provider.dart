import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/laporan_remote_datasource.dart';

/// Menyediakan keempat tab laporan owner dari endpoint `/laporan/*`.
/// Sebelumnya seluruh angkanya ditulis langsung di widget masing-masing.
class OwnerLaporanProvider extends ChangeNotifier {
  OwnerLaporanProvider({LaporanRemoteDatasource? datasource})
      : _datasource = datasource ?? LaporanRemoteDatasource();

  final LaporanRemoteDatasource _datasource;

  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  bool _isLoading = false;
  String? _error;

  LaporanRingkasan _ringkasan = LaporanRingkasan.kosong;
  LaporanProduk _produk = const LaporanProduk(items: [], kategori: []);
  List<LaporanPembayaranItem> _pembayaran = const [];
  LaporanGuest _guest = const LaporanGuest(items: [], totalTamu: 0);

  DateTime get start => _start;
  DateTime get end => _end;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LaporanRingkasan get ringkasan => _ringkasan;
  LaporanProduk get produk => _produk;
  List<LaporanPembayaranItem> get pembayaran => _pembayaran;
  LaporanGuest get guest => _guest;

  /// Memuat keempat laporan sekaligus supaya berpindah tab tidak memicu
  /// permintaan baru.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasil = await Future.wait([
        _datasource.fetchRingkasan(start: _start, end: _end),
        _datasource.fetchProduk(start: _start, end: _end),
        _datasource.fetchPembayaran(start: _start, end: _end),
        _datasource.fetchGuest(start: _start, end: _end),
      ]);
      _ringkasan = hasil[0] as LaporanRingkasan;
      _produk = hasil[1] as LaporanProduk;
      _pembayaran = hasil[2] as List<LaporanPembayaranItem>;
      _guest = hasil[3] as LaporanGuest;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat laporan.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRentang(DateTime start, DateTime end) async {
    _start = start;
    _end = end;
    await load();
  }
}
