import '../repositories/kitchen_order_repository.dart';

/// Dapur menyelesaikan sebuah pesanan (non Dine-In) → hilang dari layar dapur.
class CompleteKitchenOrderUsecase {
  const CompleteKitchenOrderUsecase(this._repository);

  final KitchenOrderRepository _repository;

  Future<void> call(String id) => _repository.completeOrder(id);
}
