import '../../../../core/network/api_client.dart';
import '../models/transaksi_model.dart';

abstract class TransaksiRemoteDatasource {
  Future<List<TransaksiModel>> fetchTransaksi({DateTime? date});
}

class TransaksiRemoteDatasourceImpl implements TransaksiRemoteDatasource {
  TransaksiRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<TransaksiModel>> fetchTransaksi({DateTime? date}) async {
    // GET /transaksi?date=YYYY-MM-DD — riwayat transaksi penjualan yang sudah
    // dibayar pada satu tanggal. Default tanggal = hari ini bila tidak dikirim.
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/transaksi',
        queryParameters: date == null
            ? null
            : {'date': date.toIso8601String().substring(0, 10)},
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => TransaksiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
