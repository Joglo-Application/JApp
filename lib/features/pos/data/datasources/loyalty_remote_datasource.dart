import '../../../../core/network/api_client.dart';

/// Satu reward pada katalog penukaran poin (`GET /loyalty/rewards`).
class LoyaltyRewardModel {
  const LoyaltyRewardModel({
    required this.rewardId,
    required this.nama,
    required this.tipe,
    required this.poin,
    this.diskonTipe,
    this.diskonNilai,
    this.menuId,
    this.namaMenu,
    this.hargaMenu,
  });

  final int rewardId;
  final String nama;

  /// `diskon` atau `produk_gratis`.
  final String tipe;
  final int poin;

  /// Untuk tipe `diskon`: `amount` atau `percent`.
  final String? diskonTipe;
  final double? diskonNilai;

  /// Untuk tipe `produk_gratis`.
  final int? menuId;
  final String? namaMenu;
  final double? hargaMenu;

  bool get isProdukGratis => tipe == 'produk_gratis';

  factory LoyaltyRewardModel.fromJson(Map<String, dynamic> json) =>
      LoyaltyRewardModel(
        rewardId: (json['rewardId'] as num).toInt(),
        nama: (json['nama'] ?? '').toString(),
        tipe: (json['tipe'] ?? 'diskon').toString(),
        poin: (json['poin'] as num?)?.toInt() ?? 0,
        diskonTipe: json['diskonTipe'] as String?,
        diskonNilai: (json['diskonNilai'] as num?)?.toDouble(),
        menuId: (json['menuId'] as num?)?.toInt(),
        namaMenu: json['namaMenu'] as String?,
        hargaMenu: (json['hargaMenu'] as num?)?.toDouble(),
      );
}

class LoyaltyRemoteDatasource {
  LoyaltyRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// POST /loyalty/rewards — menambah reward (owner/admin).
  Future<void> createReward({
    required String nama,
    required String tipe,
    required int poin,
    String? diskonTipe,
    double? diskonNilai,
    int? menuId,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/loyalty/rewards',
        data: {
          'nama': nama,
          'tipe': tipe,
          'poin': poin,
          'diskonTipe': ?diskonTipe,
          'diskonNilai': ?diskonNilai,
          'menuId': ?menuId,
        },
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// DELETE /loyalty/rewards/:id
  Future<void> deleteReward(int rewardId) async {
    try {
      await _client.dio
          .delete<Map<String, dynamic>>('/loyalty/rewards/$rewardId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// GET /loyalty/rewards — katalog reward.
  /// `semua: true` menyertakan yang nonaktif, untuk layar owner.
  Future<List<LoyaltyRewardModel>> fetchRewards({bool semua = false}) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/loyalty/rewards',
        queryParameters: semua ? {'all': 'true'} : null,
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => LoyaltyRewardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// POST /loyalty/redeem — memotong poin member di server sekaligus
  /// mencatatnya di riwayat poin.
  Future<void> redeem({
    required int memberId,
    required int rewardId,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/loyalty/redeem',
        data: {'memberId': memberId, 'rewardId': rewardId},
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
