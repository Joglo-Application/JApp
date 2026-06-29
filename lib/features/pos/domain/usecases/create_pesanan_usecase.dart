import '../entities/create_pesanan_params.dart';
import '../entities/pesanan.dart';
import '../repositories/checkout_repository.dart';

/// Creates a sales order and sends it to the kitchen ("Kirim Dapur").
class CreatePesananUseCase {
  const CreatePesananUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Pesanan> call(CreatePesananParams params) =>
      _repository.createPesanan(params);
}
