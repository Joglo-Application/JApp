import '../entities/transaksi.dart';

abstract class TransaksiRepository {
  Future<List<Transaksi>> fetchTransaksi({DateTime? date});

  /// Retur transaksi yang sudah dibayar. Butuh PIN supervisor.
  Future<void> returTransaksi({
    required String kode,
    required String alasan,
    required String pin,
  });
}
