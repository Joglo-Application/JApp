import '../entities/product.dart';
import '../entities/update_menu_params.dart';
import '../repositories/menu_repository.dart';

class UpdateMenuUseCase {
  const UpdateMenuUseCase(this._repository);

  final MenuRepository _repository;

  Future<Product> call(UpdateMenuParams params) =>
      _repository.updateMenu(params);
}
