/// Central configuration for the backend REST API.
///
/// The base URL can be overridden at build/run time without touching code:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
///
/// The default points at the deployed AWS instance.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://54.153.133.48:3000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Origin of the backend (scheme://host:port), tanpa path `/api/v1`.
  /// Gambar unggahan disajikan dari sini (`/uploads/...`), bukan di bawah API.
  static String get serverOrigin => Uri.parse(baseUrl).origin;

  /// Ubah path gambar dari server jadi URL absolut yang bisa dimuat.
  ///
  /// Backend mengembalikan path relatif seperti `/uploads/foo.jpg`; di web
  /// path relatif akan salah resolve ke origin halaman, jadi harus dijadikan
  /// absolut. URL yang sudah absolut (http/https) dibiarkan apa adanya.
  static String? resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$serverOrigin${path.startsWith('/') ? '' : '/'}$path';
  }
}
