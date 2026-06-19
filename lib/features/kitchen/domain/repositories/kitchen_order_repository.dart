import '../entities/kitchen_order.dart';

abstract interface class KitchenOrderRepository {
  Future<List<KitchenOrder>> fetchActiveOrders();
}
