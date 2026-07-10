import '../entities/log_transaksi_entry.dart';

abstract interface class LogTransaksiRepository {
  Future<List<LogTransaksiEntry>> fetchLogs({DateTime? date, String? tipe});
  Future<void> createLog({
    required String tipe,
    required String kodeTransaksi,
    required String deskripsi,
  });
}
