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
    _datasource = KitchenOrderRemoteDatasourceImpl();
    final repo = KitchenOrderRepositoryImpl(_datasource);
    _usecase = FetchKitchenOrdersUsecase(repo);
    _completeUsecase = CompleteKitchenOrderUsecase(repo);
  }

  late final KitchenOrderRemoteDatasource _datasource;
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

  /// Mencentang/membatalkan centang satu item pesanan.
  ///
  /// Statusnya disimpan di server (bukan hanya di state lokal seperti
  /// sebelumnya) supaya progres terlihat di semua perangkat dapur dan tidak
  /// hilang saat daftar dimuat ulang.
  Future<void> toggleItem(String orderId, int itemIndex) async {
    final orderIdx = _orders.indexWhere((o) => o.id == orderId);
    if (orderIdx < 0) return;

    final order = _orders[orderIdx];
    if (itemIndex < 0 || itemIndex >= order.items.length) return;

    final item = order.items[itemIndex];
    final target = !item.isDone;

    try {
      await _datasource.setItemDone(
        orderId: orderId,
        detailId: item.detailId,
        selesai: target,
      );
    } catch (_) {
      // Biarkan tampilan apa adanya bila server menolak, supaya tidak
      // menampilkan centang yang sebenarnya tidak tersimpan.
      return;
    }

    _orders = [
      for (final o in _orders)
        if (o.id == orderId)
          o.copyWith(
            items: [
              for (var i = 0; i < o.items.length; i++)
                if (i == itemIndex)
                  o.items[i].copyWith(isDone: target)
                else
                  o.items[i],
            ],
          )
        else
          o,
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
