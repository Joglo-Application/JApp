import '../../domain/entities/stok_gudang_item.dart';
import '../../domain/repositories/stok_gudang_repository.dart';
import '../datasources/stok_gudang_remote_datasource.dart';

class StokGudangRepositoryImpl implements StokGudangRepository {
  StokGudangRepositoryImpl({StokGudangRemoteDatasource? datasource})
      : _datasource = datasource ?? StokGudangRemoteDatasourceImpl();

  final StokGudangRemoteDatasource _datasource;

  @override
  Future<List<StokGudangItem>> fetchStokGudang() async {
    final models = await _datasource.fetchStokGudang();
    return models.map((m) => m.toEntity()).toList();
  }
}
