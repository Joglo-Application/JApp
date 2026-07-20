import '../../../../core/network/api_client.dart';

/// Ringkasan promo yang berlaku, untuk ditampilkan sebagai pilihan.
class PromoModel {
  const PromoModel({
    required this.kode,
    required this.nama,
    required this.tipe,
    required this.nilai,
    this.promoId = 0,
    this.mulai,
  });

  final int promoId;
  final String kode;
  final String nama;

  /// `amount` (rupiah) atau `percent`.
  final String tipe;
  final double nilai;
  final String? mulai;

  factory PromoModel.fromJson(Map<String, dynamic> json) => PromoModel(
        promoId: (json['promoId'] as num?)?.toInt() ?? 0,
        kode: (json['kode'] ?? '').toString(),
        nama: (json['nama'] ?? '').toString(),
        tipe: (json['tipe'] ?? 'amount').toString(),
        nilai: (json['nilai'] as num?)?.toDouble() ?? 0,
        mulai: json['mulai'] as String?,
      );

  /// Label ringkas, mis. "Diskon 5%" atau "Diskon Rp10.000".
  String get deskripsi => tipe == 'percent'
      ? 'Diskon ${nilai.toStringAsFixed(0)}%'
      : 'Diskon Rp${nilai.toStringAsFixed(0)}';
}

class PromoRemoteDatasource {
  PromoRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// GET /promo — hanya promo yang sedang berlaku.
  /// `semua: true` menyertakan yang nonaktif/kedaluwarsa, untuk layar owner.
  Future<List<PromoModel>> fetchPromo({bool semua = false}) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/promo',
        queryParameters: semua ? {'all': 'true'} : null,
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => PromoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// POST /promo — membuat promo baru (owner/admin).
  Future<void> createPromo({
    required String kode,
    required String nama,
    required String tipe,
    required double nilai,
    int? maxDiskon,
    String? mulai,
    String? berakhir,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/promo',
        data: {
          'kode': kode,
          'nama': nama,
          'tipe': tipe,
          'nilai': nilai,
          if (maxDiskon != null && maxDiskon > 0) 'maxDiskon': maxDiskon,
          'mulai': ?mulai,
          'berakhir': ?berakhir,
        },
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// DELETE /promo/:id
  Future<void> deletePromo(int promoId) async {
    try {
      await _client.dio.delete<Map<String, dynamic>>('/promo/$promoId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// POST /promo/validate — server yang memeriksa kode dan menghitung
  /// potongannya. Nilai yang dikembalikan sudah final dalam rupiah, sehingga
  /// besaran diskon tidak lagi dihitung (atau bisa diubah) di klien.
  Future<({String nama, double diskon})> validatePromo({
    required String kode,
    required int subtotal,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/promo/validate',
        data: {'kode': kode, 'subtotal': subtotal},
      );
      final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
      final promo = data['promo'] as Map<String, dynamic>? ?? const {};
      return (
        nama: (promo['nama'] ?? kode).toString(),
        diskon: (data['diskon'] as num?)?.toDouble() ?? 0,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
