import '../../../../core/network/api_client.dart';

class PegawaiUser {
  const PegawaiUser({
    required this.userId,
    required this.namaUser,
    required this.username,
    required this.role,
  });

  final int userId;
  final String namaUser;
  final String username;
  final String role;
}

abstract interface class PegawaiRemoteDatasource {
  Future<List<PegawaiUser>> fetchAll();
  Future<void> create({
    required String namaUser,
    required String username,
    required String password,
    required String role,
  });
  Future<void> update(
    int userId, {
    String? namaUser,
    String? username,
    String? password,
    String? role,
  });
  Future<void> delete(int userId);
}

class PegawaiRemoteDatasourceImpl implements PegawaiRemoteDatasource {
  PegawaiRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<PegawaiUser>> fetchAll() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/users',
        queryParameters: {'limit': 100},
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows.map((e) {
        final j = e as Map<String, dynamic>;
        return PegawaiUser(
          userId: (j['userId'] as num).toInt(),
          namaUser: j['namaUser'] as String,
          username: j['username'] as String,
          role: j['role'] as String,
        );
      }).toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> create({
    required String namaUser,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>('/users', data: {
        'namaUser': namaUser,
        'username': username,
        'password': password,
        'role': role,
      });
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> update(
    int userId, {
    String? namaUser,
    String? username,
    String? password,
    String? role,
  }) async {
    try {
      await _client.dio.patch<Map<String, dynamic>>('/users/$userId', data: {
        'namaUser': ?namaUser,
        'username': ?username,
        'password': ?password,
        'role': ?role,
      });
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> delete(int userId) async {
    try {
      await _client.dio.delete<Map<String, dynamic>>('/users/$userId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
