import '../../../../core/network/api_client.dart';
import '../../domain/entities/log_gudang_entry.dart';

abstract interface class LogGudangRemoteDatasource {
  Future<List<LogGudangEntry>> fetchLogs({DateTime? date, String? jenis});
  Future<void> createLog({required String jenis, required String logs});
}

class LogGudangRemoteDatasourceImpl implements LogGudangRemoteDatasource {
  LogGudangRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<LogGudangEntry>> fetchLogs({DateTime? date, String? jenis}) async {
    // GET /log-gudang?date=&jenis=
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/log-gudang',
        queryParameters: {
          'date': ?date?.toIso8601String().substring(0, 10),
          'jenis': ?jenis,
        },
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows.map((e) {
        final j = e as Map<String, dynamic>;
        return LogGudangEntry(
          tanggal: DateTime.parse(j['waktu'] as String).toLocal(),
          jenis: j['jenis'] as String,
          author: j['author'] as String,
          logs: j['logs'] as String,
        );
      }).toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> createLog({required String jenis, required String logs}) async {
    // POST /log-gudang — dipanggil saat user gudang melakukan aksi.
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/log-gudang',
        data: {'jenis': jenis, 'logs': logs},
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
