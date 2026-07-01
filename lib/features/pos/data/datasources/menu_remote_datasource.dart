import '../../../../core/network/api_client.dart';
import '../../domain/entities/create_menu_params.dart';
import '../../domain/entities/update_menu_params.dart';
import '../models/menu_model.dart';

abstract class MenuRemoteDatasource {
  Future<List<MenuModel>> fetchMenus();

  Future<MenuModel> createMenu(CreateMenuParams params);

  Future<MenuModel> updateMenu(UpdateMenuParams params);
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
  Future<MenuModel> createMenu(CreateMenuParams params) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/menus',
        data: {
          'namaMenu': params.namaMenu,
          'kategori': params.kategori,
          'harga': params.harga,
          'isActive': params.isActive,
          'stok': params.stok,
          'stokMinimum': params.stokMinimum,
          'isProdukKhusus': params.isProdukKhusus,
          if (params.royaltyPoint != null) 'royaltyPoint': params.royaltyPoint,
          if (params.isProdukKhusus && params.produkKhususMulai != null)
            'produkKhususMulai': params.produkKhususMulai,
          if (params.isProdukKhusus && params.produkKhususSelesai != null)
            'produkKhususSelesai': params.produkKhususSelesai,
          if (params.catatan != null && params.catatan!.isNotEmpty)
            'catatan': params.catatan,
          if (params.resep.isNotEmpty)
            'resep': params.resep
                .map((r) => {
                      'bahanId': r.bahanId,
                      'jumlahPakai': r.jumlahPakai,
                    })
                .toList(),
        },
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      return MenuModel.fromJson(data);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<MenuModel> updateMenu(UpdateMenuParams params) async {
    try {
      final res = await _client.dio.patch<Map<String, dynamic>>(
        '/menus/${params.id}',
        data: {
          'namaMenu': params.namaMenu,
          'kategori': params.kategori,
          'harga': params.harga,
          'isActive': params.isActive,
          'isProdukKhusus': params.isProdukKhusus,
          if (params.royaltyPoint != null) 'royaltyPoint': params.royaltyPoint,
          if (params.isProdukKhusus && params.produkKhususMulai != null)
            'produkKhususMulai': params.produkKhususMulai,
          if (params.isProdukKhusus && params.produkKhususSelesai != null)
            'produkKhususSelesai': params.produkKhususSelesai,
          if (params.catatan != null && params.catatan!.isNotEmpty)
            'catatan': params.catatan,
          if (params.resep.isNotEmpty)
            'resep': params.resep
                .map((r) => {
                      'bahanId': r.bahanId,
                      'jumlahPakai': r.jumlahPakai,
                    })
                .toList(),
        },
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      return MenuModel.fromJson(data);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
