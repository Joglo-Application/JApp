import '../../domain/entities/kitchen_order.dart';

class KitchenOrderItemModel extends KitchenOrderItem {
  const KitchenOrderItemModel({
    required super.nama,
    required super.qty,
    super.detailId,
    super.catatan,
    super.isDone,
  });

  factory KitchenOrderItemModel.fromJson(Map<String, dynamic> json) =>
      KitchenOrderItemModel(
        nama: json['nama'] as String,
        qty: json['qty'] as int,
        detailId: (json['detailId'] as num?)?.toInt() ?? 0,
        catatan: json['catatan'] as String? ?? '',
        // Status centang kini tersimpan di server, jadi ikut dimuat.
        isDone: json['selesai'] == true,
      );
}

class KitchenOrderModel extends KitchenOrder {
  const KitchenOrderModel({
    required super.id,
    required super.kodeTransaksi,
    required super.tipe,
    required super.items,
    required super.startTime,
    super.status,
  });

  factory KitchenOrderModel.fromJson(Map<String, dynamic> json) {
    final tipeStr = json['tipe'] as String;
    final tipe = tipeStr == 'TAKE-AWAY'
        ? KitchenOrderType.takeAway
        : KitchenOrderType.dineIn;

    final itemsJson = json['items'] as List<dynamic>;
    final items = itemsJson
        .map((e) => KitchenOrderItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return KitchenOrderModel(
      id: json['id'] as String,
      kodeTransaksi: json['kodeTransaksi'] as String,
      tipe: tipe,
      items: items,
      startTime: DateTime.parse(json['startTime'] as String),
    );
  }
}
