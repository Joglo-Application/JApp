import '../../../../core/network/api_client.dart';
import '../../domain/entities/log_transaksi_entry.dart';

abstract interface class LogTransaksiRemoteDatasource {
  Future<List<LogTransaksiEntry>> fetchLogs({DateTime? date, String? tipe});
  Future<void> createLog({
    required String tipe,
    required String kodeTransaksi,
    required String deskripsi,
  });
}

class LogTransaksiRemoteDatasourceImpl implements LogTransaksiRemoteDatasource {
  LogTransaksiRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<LogTransaksiEntry>> fetchLogs({DateTime? date, String? tipe}) async {
    // GET /log-transaksi?date=YYYY-MM-DD&tipe=...
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/log-transaksi',
        queryParameters: {
          'date': ?date?.toIso8601String().substring(0, 10),
          'tipe': ?tipe,
        },
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows.map((e) {
        final j = e as Map<String, dynamic>;
        return LogTransaksiEntry(
          tipe: j['tipe'] as String,
          kodeTransaksi: j['kodeTransaksi'] as String,
          namaKasir: j['namaKasir'] as String,
          deskripsi: j['deskripsi'] as String,
          waktu: DateTime.parse(j['waktu'] as String).toLocal(),
        );
      }).toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> createLog({
    required String tipe,
    required String kodeTransaksi,
    required String deskripsi,
  }) async {
    // POST /log-transaksi
    try {
      await _client.dio.post<Map<String, dynamic>>('/log-transaksi', data: {
        'tipe': tipe,
        'kodeTransaksi': kodeTransaksi,
        'deskripsi': deskripsi,
      });
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
