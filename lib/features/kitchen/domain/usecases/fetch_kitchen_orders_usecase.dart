import '../entities/kitchen_order.dart';
import '../repositories/kitchen_order_repository.dart';

class FetchKitchenOrdersUsecase {
  const FetchKitchenOrdersUsecase(this._repository);

  final KitchenOrderRepository _repository;

  Future<List<KitchenOrder>> call() => _repository.fetchActiveOrders();
}
