import '../../domain/entities/inventori_item.dart';
import '../../domain/repositories/inventori_repository.dart';
import '../datasources/inventori_remote_datasource.dart';

class InventoriRepositoryImpl implements InventoriRepository {
  InventoriRepositoryImpl({InventoriRemoteDatasource? datasource})
      : _datasource = datasource ?? InventoriRemoteDatasourceImpl();

  final InventoriRemoteDatasource _datasource;

  @override
  Future<List<InventoriItem>> fetchInventori() async {
    final models = await _datasource.fetchInventori();
    return models.map((m) => m.toEntity()).toList();
  }
}
