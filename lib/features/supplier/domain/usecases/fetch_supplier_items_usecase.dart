import '../entities/supplier_item.dart';
import '../repositories/supplier_repository.dart';

class FetchSupplierItemsUseCase {
  const FetchSupplierItemsUseCase(this._repository);

  final SupplierRepository _repository;

  Future<List<SupplierItem>> call() => _repository.fetchItems();
}
