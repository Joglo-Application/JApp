/// Normalised error thrown by the data layer.
///
/// Maps the backend error envelope
/// `{ success: false, error: { code, message, details } }`
/// into a single typed exception the UI can display.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.details,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
