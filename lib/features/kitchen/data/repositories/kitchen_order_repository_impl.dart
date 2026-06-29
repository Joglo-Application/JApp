import '../../domain/entities/kitchen_order.dart';
import '../../domain/repositories/kitchen_order_repository.dart';
import '../datasources/kitchen_order_remote_datasource.dart';

class KitchenOrderRepositoryImpl implements KitchenOrderRepository {
  const KitchenOrderRepositoryImpl(this._datasource);

  final KitchenOrderRemoteDatasource _datasource;

  @override
  Future<List<KitchenOrder>> fetchActiveOrders() =>
      _datasource.fetchActiveOrders();

  @override
  Future<void> completeOrder(String id) => _datasource.completeOrder(id);
}
