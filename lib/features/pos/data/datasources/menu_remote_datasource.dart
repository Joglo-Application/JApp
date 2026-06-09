import '../../../../core/network/api_client.dart';
import '../models/menu_model.dart';

abstract class MenuRemoteDatasource {
  Future<List<MenuModel>> fetchMenus();

  Future<MenuModel> createMenu({
    required String namaMenu,
    required String kategori,
    required int harga,
    bool isActive = true,
  });
}

class MenuRemoteDatasourceImpl implements MenuRemoteDatasource {
  MenuRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  static const int _pageSize = 100;

  @override
  Future<List<MenuModel>> fetchMenus() async {
    try {
      final models = <MenuModel>[];
      var page = 1;
      var totalPages = 1;

      do {
        final res = await _client.dio.get<Map<String, dynamic>>(
          '/menus',
          queryParameters: {'page': page, 'limit': _pageSize},
        );
        final body = res.data!;
        final rows = body['data'] as List<dynamic>;
        models.addAll(
          rows.map((e) => MenuModel.fromJson(e as Map<String, dynamic>)),
        );

        final meta = body['meta'] as Map<String, dynamic>?;
        totalPages = (meta?['totalPages'] as num?)?.toInt() ?? 1;
        page++;
      } while (page <= totalPages);

      return models;
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<MenuModel> createMenu({
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
      return MenuModel.fromJson(data);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
