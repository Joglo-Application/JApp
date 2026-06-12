import '../entities/inventori_item.dart';
import '../repositories/inventori_repository.dart';

class FetchInventoriUseCase {
  const FetchInventoriUseCase(this._repository);

  final InventoriRepository _repository;

  Future<List<InventoriItem>> call() => _repository.fetchInventori();
}
