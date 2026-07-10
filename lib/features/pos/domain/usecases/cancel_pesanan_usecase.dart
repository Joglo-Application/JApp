import '../repositories/checkout_repository.dart';

/// Membatalkan pesanan aktif (kembalikan stok, hapus dari layar dapur).
class CancelPesananUseCase {
  const CancelPesananUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<void> call(int pesananId) => _repository.cancelPesanan(pesananId);
}
