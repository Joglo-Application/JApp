import '../../domain/entities/kitchen_order.dart';
import '../models/kitchen_order_model.dart';

abstract interface class KitchenOrderRemoteDatasource {
  Future<List<KitchenOrderModel>> fetchActiveOrders();
}

class KitchenOrderRemoteDatasourceImpl implements KitchenOrderRemoteDatasource {
  @override
  Future<List<KitchenOrderModel>> fetchActiveOrders() async {
    // Replace with real API call
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      KitchenOrderModel(
        id: '1',
        kodeTransaksi: 'TRX-001',
        tipe: KitchenOrderType.takeAway,
        startTime: DateTime.now(),
        items: const [
          KitchenOrderItemModel(nama: 'Burger Sapi', qty: 2, catatan: '*** Pedas'),
          KitchenOrderItemModel(nama: 'Lemon Squash', qty: 2),
          KitchenOrderItemModel(nama: 'Americano', qty: 1),
        ],
      ),
      KitchenOrderModel(
        id: '2',
        kodeTransaksi: 'TRX-002',
        tipe: KitchenOrderType.dineIn,
        startTime: DateTime.now(),
        items: const [
          KitchenOrderItemModel(nama: 'Burger Sapi', qty: 1),
          KitchenOrderItemModel(nama: 'Lemon Squash', qty: 4),
        ],
      ),
    ];
  }
}
