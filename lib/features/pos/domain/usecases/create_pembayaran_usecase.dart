import '../entities/pembayaran.dart';
import '../repositories/checkout_repository.dart';

/// Processes payment for a pending order.
class CreatePembayaranUseCase {
  const CreatePembayaranUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Pembayaran> call({
    required int pesananId,
    required String metode,
    required int jumlahBayar,
  }) =>
      _repository.createPembayaran(
        pesananId: pesananId,
        metode: metode,
        jumlahBayar: jumlahBayar,
      );
}
