import '../../../../core/network/api_client.dart';
import '../../domain/entities/absensi_record.dart';

abstract interface class AbsensiRemoteDatasource {
  Future<List<AbsensiRecord>> fetchAbsensi({DateTime? date});
  Future<void> absenMasuk();
  Future<void> absenKeluar();
}

class AbsensiRemoteDatasourceImpl implements AbsensiRemoteDatasource {
  AbsensiRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  static String _fmtTime(String iso) {
    final d = DateTime.parse(iso).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  @override
  Future<List<AbsensiRecord>> fetchAbsensi({DateTime? date}) async {
    // GET /absensi?date=
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/absensi',
        queryParameters: {
          'date': ?date?.toIso8601String().substring(0, 10),
        },
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows.map((e) {
        final j = e as Map<String, dynamic>;
        return AbsensiRecord(
          nama: j['nama'] as String,
          tanggal: DateTime.parse(j['tanggal'] as String),
          jamMasuk: _fmtTime(j['jamMasuk'] as String),
          jamKeluar:
              j['jamKeluar'] == null ? '-' : _fmtTime(j['jamKeluar'] as String),
        );
      }).toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> absenMasuk() async {
    try {
      await _client.dio.post<Map<String, dynamic>>('/absensi/masuk');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> absenKeluar() async {
    try {
      await _client.dio.post<Map<String, dynamic>>('/absensi/keluar');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
