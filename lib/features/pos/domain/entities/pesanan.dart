/// Result of creating a sales order (`POST /pesanan`).
///
/// Totals (subtotal, service charge, tax, total) are computed server-side and
/// stock is auto-deducted. Status starts as `pending` until payment completes.
class Pesanan {
  const Pesanan({
    required this.pesananId,
    required this.status,
    required this.total,
  });

  final int pesananId;
  final String status;
  final double total;
}
