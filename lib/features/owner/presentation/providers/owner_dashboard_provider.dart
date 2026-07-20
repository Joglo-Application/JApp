import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/laporan_remote_datasource.dart';

class OwnerDailyData {
  const OwnerDailyData({required this.date, required this.value});
  final DateTime date;
  final double value;
}

class OwnerTopEntry {
  const OwnerTopEntry({
    required this.kategori,
    required this.nama,
    required this.jumlah,
  });
  final String kategori;
  final String nama;
  final int jumlah;
}

class OwnerDashboardProvider extends ChangeNotifier {
  OwnerDashboardProvider({LaporanRemoteDatasource? datasource})
      : _datasource = datasource ?? LaporanRemoteDatasource() {
    _initDates();
    load();
  }

  final LaporanRemoteDatasource _datasource;

  late DateTime startDate;
  late DateTime endDate;
  bool isLoading = false;
  String? error;

  double pendapatan = 0;
  double pengeluaran = 0;
  double pengembalianPenjualan = 0;

  double totalPenjualan = 0;
  double penjualanKotor = 0;
  int jumlahTransaksi = 0;
  double penerimaan = 0;

  List<OwnerDailyData> dailyPendapatan = const [];
  List<OwnerDailyData> dailyPengeluaran = const [];
  List<OwnerTopEntry> topKategoriProduk = const [];
  List<OwnerTopEntry> topProdukToko = const [];

  void _initDates() {
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);
  }

  /// Seluruh isi dashboard datang dari satu panggilan `GET /laporan/dashboard`
  /// — ringkasan, deret harian, dan top produk/kategori sekaligus.
  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final d = await _datasource.fetchDashboard(start: startDate, end: endDate);
      final r = d.ringkasan;

      pendapatan = r.pendapatan;
      pengeluaran = r.pengeluaran;
      pengembalianPenjualan = r.retur;
      totalPenjualan = r.pendapatan;
      penjualanKotor = r.subtotal;
      jumlahTransaksi = r.pesananDiterima;
      penerimaan = r.pendapatanBersih;

      dailyPendapatan = d.harian
          .map((e) => OwnerDailyData(date: e.tanggal, value: e.pendapatan))
          .toList();
      dailyPengeluaran = d.harian
          .map((e) => OwnerDailyData(date: e.tanggal, value: e.pengeluaran))
          .toList();

      topKategoriProduk = d.topKategori
          .map((e) => OwnerTopEntry(
                kategori: e.kategori,
                nama: e.kategori,
                jumlah: e.qty,
              ))
          .toList();
      topProdukToko = d.topProduk
          .map((e) => OwnerTopEntry(
                kategori: e.kategori,
                nama: e.nama,
                jumlah: e.qty,
              ))
          .toList();
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Gagal memuat dashboard.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeDateRange(DateTime start, DateTime end) async {
    startDate = start;
    endDate = end;
    notifyListeners();
    await load();
  }
}
