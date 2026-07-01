import '../../domain/entities/create_menu_params.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/update_menu_params.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl({MenuRemoteDatasource? datasource})
      : _datasource = datasource ?? MenuRemoteDatasourceImpl();

  final MenuRemoteDatasource _datasource;

  @override
  Future<List<Product>> fetchMenus() async {
    final models = await _datasource.fetchMenus();
    return models.map((m) => m.toProduct()).toList();
  }

  @override
  Future<Product> createMenu(CreateMenuParams params) async {
    final model = await _datasource.createMenu(params);
    return model.toProduct();
  }

  @override
  Future<Product> updateMenu(UpdateMenuParams params) async {
    final model = await _datasource.updateMenu(params);
    return model.toProduct();
  }
}
