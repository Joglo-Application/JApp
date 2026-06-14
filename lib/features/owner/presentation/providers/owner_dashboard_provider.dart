import 'package:flutter/foundation.dart';

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
  OwnerDashboardProvider() {
    _initDates();
    load();
  }

  late DateTime startDate;
  late DateTime endDate;
  bool isLoading = false;

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

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    // TODO: replace with real API calls
    await Future.delayed(const Duration(milliseconds: 300));

    pendapatan = 1270600;
    pengeluaran = 200000;
    pengembalianPenjualan = 280700;
    totalPenjualan = 989900;
    penjualanKotor = 949300;
    jumlahTransaksi = 132;
    penerimaan = 989000;

    final base = DateTime(2025, 8, 13);
    dailyPendapatan = [
      OwnerDailyData(date: base, value: 1602300),
      OwnerDailyData(date: base.add(const Duration(days: 1)), value: 450000),
      OwnerDailyData(date: base.add(const Duration(days: 2)), value: 1270600),
      OwnerDailyData(date: base.add(const Duration(days: 3)), value: 300000),
    ];
    dailyPengeluaran = [
      OwnerDailyData(date: base, value: 430000),
      OwnerDailyData(date: base.add(const Duration(days: 1)), value: 50000),
      OwnerDailyData(date: base.add(const Duration(days: 2)), value: 200000),
      OwnerDailyData(date: base.add(const Duration(days: 3)), value: 100000),
    ];

    topKategoriProduk = [
      const OwnerTopEntry(kategori: 'Makanan', nama: 'Produk', jumlah: 0),
    ];
    topProdukToko = [
      const OwnerTopEntry(kategori: 'Makanan', nama: 'Produk', jumlah: 0),
    ];

    isLoading = false;
    notifyListeners();
  }

  Future<void> changeDateRange(DateTime start, DateTime end) async {
    startDate = start;
    endDate = end;
    notifyListeners();
    await load();
  }
}
