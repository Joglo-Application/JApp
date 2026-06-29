import '../../../../core/network/api_client.dart';
import '../models/stok_gudang_item_model.dart';

abstract class StokGudangRemoteDatasource {
  Future<List<StokGudangItemModel>> fetchStokGudang();
}

class StokGudangRemoteDatasourceImpl implements StokGudangRemoteDatasource {
  StokGudangRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<StokGudangItemModel>> fetchStokGudang() async {
    // GET /stok-gudang — stok bahan baku untuk owner.
    try {
      final res = await _client.dio.get<Map<String, dynamic>>('/stok-gudang');
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => StokGudangItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
