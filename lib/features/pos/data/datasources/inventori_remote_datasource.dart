import '../../../../core/network/api_client.dart';
import '../models/inventori_item_model.dart';

abstract class InventoriRemoteDatasource {
  Future<List<InventoriItemModel>> fetchInventori();
}

class InventoriRemoteDatasourceImpl implements InventoriRemoteDatasource {
  InventoriRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<InventoriItemModel>> fetchInventori() async {
    // GET /inventori — stok produk (dari master menu) untuk POS.
    try {
      final res = await _client.dio.get<Map<String, dynamic>>('/inventori');
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => InventoriItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
