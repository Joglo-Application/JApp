enum KitchenOrderType { dineIn, takeAway }

extension KitchenOrderTypeLabel on KitchenOrderType {
  String get label => switch (this) {
        KitchenOrderType.dineIn => 'DINE-IN',
        KitchenOrderType.takeAway => 'TAKE-AWAY',
      };
}

enum KitchenOrderStatus { inProgress, done, cancelled }

class KitchenOrderItem {
  const KitchenOrderItem({
    required this.nama,
    required this.qty,
    this.catatan = '',
    this.isDone = false,
  });

  final String nama;
  final int qty;
  final String catatan;
  final bool isDone;

  KitchenOrderItem copyWith({bool? isDone}) => KitchenOrderItem(
        nama: nama,
        qty: qty,
        catatan: catatan,
        isDone: isDone ?? this.isDone,
      );
}

class KitchenOrder {
  const KitchenOrder({
    required this.id,
    required this.kodeTransaksi,
    required this.tipe,
    required this.items,
    required this.startTime,
    this.status = KitchenOrderStatus.inProgress,
  });

  final String id;
  final String kodeTransaksi;
  final KitchenOrderType tipe;
  final List<KitchenOrderItem> items;
  final DateTime startTime;
  final KitchenOrderStatus status;

  KitchenOrder copyWith({
    List<KitchenOrderItem>? items,
    KitchenOrderStatus? status,
  }) =>
      KitchenOrder(
        id: id,
        kodeTransaksi: kodeTransaksi,
        tipe: tipe,
        items: items ?? this.items,
        startTime: startTime,
        status: status ?? this.status,
      );
}
