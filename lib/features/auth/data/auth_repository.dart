import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'models/auth_user_model.dart';

/// Talks to the `/auth/*` endpoints and owns token persistence.
class AuthRepository {
  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// POST /auth/login → stores the JWT and returns the user.
  Future<AuthUser> login(String username, String password) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'username': username.trim(), 'password': password},
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      await TokenStorage.instance.saveToken(data['token'] as String);
      return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// GET /auth/me → validates the stored token and returns the current user.
  Future<AuthUser> me() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>('/auth/me');
      return AuthUser.fromJson(res.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<void> logout() => TokenStorage.instance.clear();
}
