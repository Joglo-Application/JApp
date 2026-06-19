import 'package:flutter/foundation.dart';

import '../../data/datasources/kitchen_order_remote_datasource.dart';
import '../../data/repositories/kitchen_order_repository_impl.dart';
import '../../domain/entities/kitchen_order.dart';
import '../../domain/usecases/fetch_kitchen_orders_usecase.dart';

enum KitchenOrderLoadState { idle, loading, loaded, error }

class KitchenOrderProvider extends ChangeNotifier {
  KitchenOrderProvider()
      : _usecase = FetchKitchenOrdersUsecase(
          KitchenOrderRepositoryImpl(KitchenOrderRemoteDatasourceImpl()),
        );

  final FetchKitchenOrdersUsecase _usecase;

  List<KitchenOrder> _orders = [];
  KitchenOrderLoadState _state = KitchenOrderLoadState.idle;

  List<KitchenOrder> get orders => _orders;
  KitchenOrderLoadState get state => _state;
  bool get isLoading => _state == KitchenOrderLoadState.loading;

  Future<void> fetch() async {
    _state = KitchenOrderLoadState.loading;
    notifyListeners();
    try {
      _orders = await _usecase();
      _state = KitchenOrderLoadState.loaded;
    } catch (_) {
      _state = KitchenOrderLoadState.error;
    }
    notifyListeners();
  }

  void toggleItem(String orderId, int itemIndex) {
    _orders = [
      for (final order in _orders)
        if (order.id == orderId)
          order.copyWith(
            items: [
              for (var i = 0; i < order.items.length; i++)
                if (i == itemIndex)
                  order.items[i].copyWith(isDone: !order.items[i].isDone)
                else
                  order.items[i],
            ],
          )
        else
          order,
    ];
    notifyListeners();
  }

  void markOrderDone(String orderId) {
    _orders = [
      for (final order in _orders)
        if (order.id == orderId)
          order.copyWith(status: KitchenOrderStatus.done)
        else
          order,
    ];
    notifyListeners();
  }
}
