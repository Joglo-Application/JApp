/// Result of paying for an order (`POST /pembayaran`).
///
/// The server validates `jumlahBayar >= total`, computes `kembalian` (change),
/// and atomically marks the order `completed`.
class Pembayaran {
  const Pembayaran({
    required this.pembayaranId,
    required this.pesananId,
    required this.metode,
    required this.jumlahBayar,
    required this.kembalian,
  });

  final int pembayaranId;
  final int pesananId;
  final String metode;
  final double jumlahBayar;
  final double kembalian;
}
