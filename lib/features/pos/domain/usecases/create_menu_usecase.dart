import '../entities/product.dart';
import '../repositories/menu_repository.dart';

class CreateMenuUseCase {
  const CreateMenuUseCase(this._repository);

  final MenuRepository _repository;

  Future<Product> call({
    required String namaMenu,
    required String kategori,
    required int harga,
    bool isActive = true,
  }) =>
      _repository.createMenu(
        namaMenu: namaMenu,
        kategori: kategori,
        harga: harga,
        isActive: isActive,
      );
}
