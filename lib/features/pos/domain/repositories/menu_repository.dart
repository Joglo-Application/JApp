import '../entities/create_menu_params.dart';
import '../entities/product.dart';
import '../entities/update_menu_params.dart';

abstract class MenuRepository {
  Future<List<Product>> fetchMenus();

  Future<Product> createMenu(CreateMenuParams params);

  Future<Product> updateMenu(UpdateMenuParams params);
}
