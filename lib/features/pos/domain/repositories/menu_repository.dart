import '../entities/product.dart';

abstract class MenuRepository {
  Future<List<Product>> fetchMenus();

  Future<Product> createMenu({
    required String namaMenu,
    required String kategori,
    required int harga,
    bool isActive = true,
  });
}
