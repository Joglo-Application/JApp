import '../../../../core/network/api_client.dart';
import '../models/kitchen_order_model.dart';

abstract interface class KitchenOrderRemoteDatasource {
  Future<List<KitchenOrderModel>> fetchActiveOrders();
  Future<void> completeOrder(String id);
}

class KitchenOrderRemoteDatasourceImpl implements KitchenOrderRemoteDatasource {
  KitchenOrderRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<KitchenOrderModel>> fetchActiveOrders() async {
    // GET /kitchen/orders — order aktif (pesanan pending) untuk layar dapur.
    try {
      final res =
          await _client.dio.get<Map<String, dynamic>>('/kitchen/orders');
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => KitchenOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> completeOrder(String id) async {
    // PATCH /kitchen/orders/:id/done — dapur menyelesaikan pesanan (non Dine-In).
    try {
      await _client.dio.patch<Map<String, dynamic>>('/kitchen/orders/$id/done');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
