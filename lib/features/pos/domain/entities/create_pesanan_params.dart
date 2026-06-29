// Input for `POST /pesanan`. The server computes totals and deducts stock,
// so the client only sends line items and order-level metadata.

/// A single order line — either a catalog menu item ([menuId]) or a custom
/// item ([namaCustom] + [hargaSatuan]).
class CreatePesananItemParams {
  const CreatePesananItemParams({
    this.menuId,
    this.namaCustom,
    this.hargaSatuan,
    required this.jumlah,
    this.diskon = 0,
    this.catatan,
  });

  final int? menuId;
  final String? namaCustom;
  final int? hargaSatuan;
  final int jumlah;

  /// Nominal discount for this line (per-row).
  final int diskon;
  final String? catatan;
}

/// Order-level discount (`amount` or `percent`).
class OrderDiscountParams {
  const OrderDiscountParams({
    required this.tipe,
    required this.nilai,
    this.promoNama,
  });

  final String tipe; // 'amount' | 'percent'
  final double nilai;
  final String? promoNama;
}

class CreatePesananParams {
  const CreatePesananParams({
    required this.items,
    this.customerNama,
    this.orderType,
    this.catatan,
    this.mejaId,
    this.memberId,
    this.diskon,
    this.hold = false,
  });

  final List<CreatePesananItemParams> items;
  final String? customerNama;

  /// API enum: dine_in | take_away | gofood | grabfood | shopeefood.
  final String? orderType;
  final String? catatan;
  final int? mejaId;
  final int? memberId;
  final OrderDiscountParams? diskon;

  /// true = simpan sebagai draft "held" (parkir): tanpa potong stok / ke dapur.
  final bool hold;
}
