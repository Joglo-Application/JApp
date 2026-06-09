import '../../domain/entities/product.dart';
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
  Future<Product> createMenu({
    required String namaMenu,
    required String kategori,
    required int harga,
    bool isActive = true,
  }) async {
    final model = await _datasource.createMenu(
      namaMenu: namaMenu,
      kategori: kategori,
      harga: harga,
      isActive: isActive,
    );
    return model.toProduct();
  }
}
