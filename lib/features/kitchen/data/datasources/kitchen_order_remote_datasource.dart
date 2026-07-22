import '../../../../core/network/api_client.dart';
import '../models/kitchen_order_model.dart';

abstract interface class KitchenOrderRemoteDatasource {
  /// [date] dalam format `YYYY-MM-DD`; bila null server memakai hari berjalan.
  /// [status] cakupan: `in_progress` (default), `completed`, atau `all`.
  Future<List<KitchenOrderModel>> fetchActiveOrders({String? date, String? status});
  Future<void> completeOrder(String id);

  /// Mencentang satu item pesanan agar progresnya terlihat di semua
  /// perangkat dapur.
  Future<void> setItemDone({
    required String orderId,
    required int detailId,
    required bool selesai,
  });
}

class KitchenOrderRemoteDatasourceImpl implements KitchenOrderRemoteDatasource {
  KitchenOrderRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<KitchenOrderModel>> fetchActiveOrders({
    String? date,
    String? status,
  }) async {
    // GET /kitchen/orders?date=&status= — order untuk layar dapur/transaksi.
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/kitchen/orders',
        queryParameters: {'date': ?date, 'status': ?status},
      );
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

  @override
  Future<void> setItemDone({
    required String orderId,
    required int detailId,
    required bool selesai,
  }) async {
    // PATCH /kitchen/orders/:id/items/:detailId/done
    try {
      await _client.dio.patch<Map<String, dynamic>>(
        '/kitchen/orders/$orderId/items/$detailId/done',
        data: {'selesai': selesai},
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
