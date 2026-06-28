import '../../domain/entities/supplier_item.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_datasource.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl({SupplierRemoteDatasource? datasource})
      : _datasource = datasource ?? SupplierRemoteDatasourceImpl();

  final SupplierRemoteDatasource _datasource;

  @override
  Future<List<SupplierItem>> fetchItems() async {
    final models = await _datasource.fetchItems();
    return models.map((m) => m.toEntity()).toList();
  }
}
