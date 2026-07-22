import '../../../../core/network/api_client.dart';

/// Kategori master di server (`menu`, `stok`, atau `stok_gudang`).
class KategoriModel {
  const KategoriModel({
    required this.kategoriId,
    required this.nama,
    required this.urutan,
    this.produkCount = 0,
  });

  final int kategoriId;
  final String nama;
  final int urutan;

  /// Jumlah produk pada kategori ini (dihitung server).
  final int produkCount;

  factory KategoriModel.fromJson(Map<String, dynamic> json) => KategoriModel(
        kategoriId: (json['kategoriId'] as num).toInt(),
        nama: (json['nama'] ?? '').toString(),
        urutan: (json['urutan'] as num?)?.toInt() ?? 0,
        produkCount: (json['produkCount'] as num?)?.toInt() ?? 0,
      );
}

class KategoriRemoteDatasource {
  KategoriRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<KategoriModel>> fetch(String jenis) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/kategori',
        queryParameters: {'jenis': jenis},
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => KategoriModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<KategoriModel> create({
    required String jenis,
    required String nama,
    int urutan = 0,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/kategori',
        data: {'jenis': jenis, 'nama': nama, 'urutan': urutan},
      );
      return KategoriModel.fromJson(res.data?['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<void> update(int kategoriId, {String? nama, int? urutan}) async {
    try {
      await _client.dio.patch<Map<String, dynamic>>(
        '/kategori/$kategoriId',
        data: {'nama': ?nama, 'urutan': ?urutan},
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<void> delete(int kategoriId) async {
    try {
      await _client.dio.delete<Map<String, dynamic>>('/kategori/$kategoriId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
