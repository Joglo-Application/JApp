import '../entities/create_menu_params.dart';
import '../entities/product.dart';

abstract class MenuRepository {
  Future<List<Product>> fetchMenus();

  Future<Product> createMenu(CreateMenuParams params);
}
