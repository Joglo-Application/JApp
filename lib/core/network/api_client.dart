import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper around a configured [Dio] instance.
///
/// Responsibilities:
///  - inject the `Authorization: Bearer <token>` header on every request,
///  - clear the token and notify the app on a `401`,
///  - translate transport/backend errors into [ApiException].
///
/// Repositories read the raw `{ success, data, meta }` envelope from the
/// returned [Response] (see e.g. AuthRepository).
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await TokenStorage.instance.clear();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  Dio get dio => _dio;

  /// Invoked once when a request fails with `401` (token already cleared).
  /// The app wires this to redirect to the login screen.
  void Function()? onUnauthorized;

  /// Converts any thrown error into a user-facing [ApiException].
  ApiException toApiException(Object error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] is Map) {
        final err = data['error'] as Map;
        return ApiException(
          (err['message'] ?? 'Terjadi kesalahan').toString(),
          code: err['code']?.toString(),
          statusCode: error.response?.statusCode,
          details: err['details'] is Map
              ? Map<String, dynamic>.from(err['details'] as Map)
              : null,
        );
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ApiException('Koneksi timeout. Periksa jaringan Anda.');
        case DioExceptionType.connectionError:
          return const ApiException(
            'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
          );
        default:
          return ApiException(
            error.message ?? 'Terjadi kesalahan jaringan.',
            statusCode: error.response?.statusCode,
          );
      }
    }

    return ApiException(error.toString());
  }
}
