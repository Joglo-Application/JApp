import '../entities/transaksi.dart';
import '../repositories/transaksi_repository.dart';

class FetchTransaksiUseCase {
  const FetchTransaksiUseCase(this._repository);

  final TransaksiRepository _repository;

  Future<List<Transaksi>> call({DateTime? date}) =>
      _repository.fetchTransaksi(date: date);
}
