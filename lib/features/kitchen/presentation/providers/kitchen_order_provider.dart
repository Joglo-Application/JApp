import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/kitchen_order_remote_datasource.dart';
import '../../data/repositories/kitchen_order_repository_impl.dart';
import '../../domain/entities/kitchen_order.dart';
import '../../domain/usecases/complete_kitchen_order_usecase.dart';
import '../../domain/usecases/fetch_kitchen_orders_usecase.dart';

enum KitchenOrderLoadState { idle, loading, loaded, error }

class KitchenOrderProvider extends ChangeNotifier {
  KitchenOrderProvider() {
    final repo = KitchenOrderRepositoryImpl(KitchenOrderRemoteDatasourceImpl());
    _usecase = FetchKitchenOrdersUsecase(repo);
    _completeUsecase = CompleteKitchenOrderUsecase(repo);
  }

  late final FetchKitchenOrdersUsecase _usecase;
  late final CompleteKitchenOrderUsecase _completeUsecase;

  List<KitchenOrder> _orders = [];
  KitchenOrderLoadState _state = KitchenOrderLoadState.idle;
  String? _error;

  List<KitchenOrder> get orders => _orders;
  KitchenOrderLoadState get state => _state;
  bool get isLoading => _state == KitchenOrderLoadState.loading;
  String? get error => _error;

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

  /// Menyelesaikan pesanan di dapur (PATCH /kitchen/orders/:id/done) lalu
  /// memuat ulang daftar dari server. Mengembalikan `false` bila gagal
  /// (pesan ada di [error]).
  Future<bool> completeOrder(String orderId) async {
    _error = null;
    try {
      await _completeUsecase(orderId);
      await fetch();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Gagal menyelesaikan pesanan';
      notifyListeners();
      return false;
    }
  }
}
