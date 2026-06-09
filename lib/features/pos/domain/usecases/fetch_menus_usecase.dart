import '../entities/product.dart';
import '../repositories/menu_repository.dart';

class FetchMenusUseCase {
  const FetchMenusUseCase(this._repository);

  final MenuRepository _repository;

  Future<List<Product>> call() => _repository.fetchMenus();
}
