import '../../../../core/network/api_client.dart';

/// Akses pengaturan yang dikelompokkan per grup di server
/// (`toko`, `pos`, `pajak`, `mataUang`, `notifikasi`, `printer`, `absensi`).
///
/// Server selalu mengembalikan bentuk lengkap beserta nilai default, jadi
/// pemanggil tidak perlu menangani grup yang belum pernah disimpan.
class PengaturanRemoteDatasource {
  PengaturanRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchGrup(String grup) async {
    try {
      final res =
          await _client.dio.get<Map<String, dynamic>>('/pengaturan/$grup');
      return res.data?['data'] as Map<String, dynamic>? ?? const {};
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Menyimpan sebagian field pun aman: server menggabungkannya dengan nilai
  /// yang sudah tersimpan, jadi field yang tidak dikirim tidak terhapus.
  Future<Map<String, dynamic>> simpanGrup(
    String grup,
    Map<String, dynamic> nilai,
  ) async {
    try {
      final res = await _client.dio.put<Map<String, dynamic>>(
        '/pengaturan/$grup',
        data: nilai,
      );
      return res.data?['data'] as Map<String, dynamic>? ?? const {};
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
