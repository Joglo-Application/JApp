import '../../../../core/network/api_client.dart';

class MetodePembayaranModel {
  const MetodePembayaranModel({
    required this.metodeId,
    required this.nama,
    required this.kode,
  });

  final int metodeId;
  final String nama;
  final String kode;

  factory MetodePembayaranModel.fromJson(Map<String, dynamic> json) =>
      MetodePembayaranModel(
        metodeId: (json['metodeId'] as num).toInt(),
        nama: (json['nama'] ?? '').toString(),
        kode: (json['kode'] ?? 'cash').toString(),
      );
}

class MetodePembayaranRemoteDatasource {
  MetodePembayaranRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// Menebak kode teknis dari nama yang diketik owner.
  ///
  /// Form hanya meminta nama tampilan dan ikon, sedangkan server menyimpan
  /// kode yang dipakai saat mencatat pembayaran. Untuk nama yang tidak
  /// dikenali, kode jatuh ke `cash` — perlu pemilih kode di form bila nanti
  /// ada metode yang namanya tidak menyiratkan jenisnya.
  static String tebakKode(String nama) {
    final n = nama.toLowerCase();
    if (n.contains('qris')) return 'qris';
    if (n.contains('debit') || n.contains('kartu')) return 'debit';
    if (n.contains('transfer') || n.contains('bank')) return 'transfer';
    return 'cash';
  }

  Future<List<MetodePembayaranModel>> fetch() async {
    try {
      final res =
          await _client.dio.get<Map<String, dynamic>>('/metode-pembayaran');
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => MetodePembayaranModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<void> create({
    required String nama,
    required String kode,
    int urutan = 0,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/metode-pembayaran',
        data: {'nama': nama, 'kode': kode, 'urutan': urutan},
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<void> delete(int metodeId) async {
    try {
      await _client.dio
          .delete<Map<String, dynamic>>('/metode-pembayaran/$metodeId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
