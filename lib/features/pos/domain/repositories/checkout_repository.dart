import '../entities/create_pesanan_params.dart';
import '../entities/pembayaran.dart';
import '../entities/pesanan.dart';

/// Drives the POS checkout: create the order (sends to kitchen, deducts stock),
/// then pay for it.
abstract class CheckoutRepository {
  Future<Pesanan> createPesanan(CreatePesananParams params);

  Future<Pembayaran> createPembayaran({
    required int pesananId,
    required String metode,
    required int jumlahBayar,
  });

  /// Batalkan pesanan aktif (kembalikan stok, hapus dari dapur).
  Future<void> cancelPesanan(int pesananId);
}
