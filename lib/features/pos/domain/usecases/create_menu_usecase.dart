import '../entities/create_menu_params.dart';
import '../entities/product.dart';
import '../repositories/menu_repository.dart';

class CreateMenuUseCase {
  const CreateMenuUseCase(this._repository);

  final MenuRepository _repository;

  Future<Product> call(CreateMenuParams params) =>
      _repository.createMenu(params);
}
