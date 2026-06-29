import '../../../../core/network/api_client.dart';
import '../models/meja_model.dart';

abstract class MejaRemoteDatasource {
  Future<List<MejaModel>> fetchMeja();

  /// PATCH /meja/{id}/status — status: available | occupied | reserved.
  Future<void> updateStatus(int mejaId, String status);
}

class MejaRemoteDatasourceImpl implements MejaRemoteDatasource {
  MejaRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<MejaModel>> fetchMeja() async {
    // GET /meja — daftar meja (read; semua role login).
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/meja',
        queryParameters: {'limit': 100},
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => MejaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> updateStatus(int mejaId, String status) async {
    try {
      await _client.dio.patch<Map<String, dynamic>>(
        '/meja/$mejaId/status',
        data: {'status': status},
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
