import '../../../core/network/api_client.dart';
import '../domain/entities/product.dart';
import 'models/menu_model.dart';

/// Talks to the `/menus` endpoints. Mirrors `AuthRepository`.
class MenuRepository {
  MenuRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// Page size for `/menus` (the backend caps `limit` at 100).
  static const int _pageSize = 100;

  /// GET /menus → every menu, paging through all results, as [Product]s.
  Future<List<Product>> fetchMenus() async {
    try {
      final products = <Product>[];
      var page = 1;
      var totalPages = 1;

      do {
        final res = await _client.dio.get<Map<String, dynamic>>(
          '/menus',
          queryParameters: {'page': page, 'limit': _pageSize},
        );
        final body = res.data!;
        final rows = body['data'] as List<dynamic>;
        products.addAll(
          rows.map(
            (e) => MenuModel.fromJson(e as Map<String, dynamic>).toProduct(),
          ),
        );

        final meta = body['meta'] as Map<String, dynamic>?;
        totalPages = (meta?['totalPages'] as num?)?.toInt() ?? 1;
        page++;
      } while (page <= totalPages);

      return products;
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// POST /menus → creates a new menu (admin only). Returns the created menu
  /// mapped to a [Product].
  Future<Product> createMenu({
    required String namaMenu,
    required String kategori,
    required int harga,
    bool isActive = true,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/menus',
        data: {
          'namaMenu': namaMenu,
          'kategori': kategori,
          'harga': harga,
          'isActive': isActive,
        },
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      return MenuModel.fromJson(data).toProduct();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
