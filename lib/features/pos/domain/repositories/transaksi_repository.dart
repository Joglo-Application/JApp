import '../entities/transaksi.dart';

abstract class TransaksiRepository {
  Future<List<Transaksi>> fetchTransaksi({DateTime? date});
}
