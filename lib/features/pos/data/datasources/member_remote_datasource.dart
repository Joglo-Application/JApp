import '../../../../core/network/api_client.dart';
import '../models/member_model.dart';

abstract class MemberRemoteDatasource {
  Future<List<MemberModel>> fetchMembers({String? q});
}

class MemberRemoteDatasourceImpl implements MemberRemoteDatasource {
  MemberRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<MemberModel>> fetchMembers({String? q}) async {
    // GET /member?q= — daftar member (read; semua role login).
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/member',
        queryParameters: {
          'limit': 100,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
