import '../entities/stok_gudang_item.dart';
import '../repositories/stok_gudang_repository.dart';

class FetchStokGudangUseCase {
  const FetchStokGudangUseCase(this._repository);
  final StokGudangRepository _repository;
  Future<List<StokGudangItem>> call() => _repository.fetchStokGudang();
}
