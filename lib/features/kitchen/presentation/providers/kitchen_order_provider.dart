import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/kitchen_order_remote_datasource.dart';
import '../../data/repositories/kitchen_order_repository_impl.dart';
import '../../domain/entities/kitchen_order.dart';
import '../../domain/usecases/complete_kitchen_order_usecase.dart';
import '../../domain/usecases/fetch_kitchen_orders_usecase.dart';

enum KitchenOrderLoadState { idle, loading, loaded, error }

class KitchenOrderProvider extends ChangeNotifier {
  /// [includeCompleted] true untuk tab Transaksi (menampilkan pesanan yang
  /// sudah selesai juga); false untuk layar Dapur (hanya sedang diproses).
  KitchenOrderProvider({this.includeCompleted = false}) {
    _datasource = KitchenOrderRemoteDatasourceImpl();
    final repo = KitchenOrderRepositoryImpl(_datasource);
    _usecase = FetchKitchenOrdersUsecase(repo);
    _completeUsecase = CompleteKitchenOrderUsecase(repo);
  }

  final bool includeCompleted;

  late final KitchenOrderRemoteDatasource _datasource;
  late final FetchKitchenOrdersUsecase _usecase;
  late final CompleteKitchenOrderUsecase _completeUsecase;

  List<KitchenOrder> _orders = [];
  KitchenOrderLoadState _state = KitchenOrderLoadState.idle;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<KitchenOrder> get orders => _orders;
  KitchenOrderLoadState get state => _state;
  bool get isLoading => _state == KitchenOrderLoadState.loading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  static String _asQuery(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> fetch() async {
    _state = KitchenOrderLoadState.loading;
    notifyListeners();
    try {
      _orders = await _usecase(
        date: _asQuery(_selectedDate),
        status: includeCompleted ? 'all' : null,
      );
      _state = KitchenOrderLoadState.loaded;
    } catch (_) {
      _state = KitchenOrderLoadState.error;
    }
    notifyListeners();
  }

  /// Berpindah tanggal lalu memuat ulang daftar dari server.
  Future<void> changeDate(DateTime date) async {
    if (_asQuery(date) == _asQuery(_selectedDate)) return;
    _selectedDate = date;
    await fetch();
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
