import '../entities/kitchen_order.dart';

abstract interface class KitchenOrderRepository {
  Future<List<KitchenOrder>> fetchActiveOrders({String? date, String? status});
  Future<void> completeOrder(String id);
}
