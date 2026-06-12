import '../../domain/entities/transaksi.dart';
import '../../domain/repositories/transaksi_repository.dart';
import '../datasources/transaksi_remote_datasource.dart';

class TransaksiRepositoryImpl implements TransaksiRepository {
  TransaksiRepositoryImpl({TransaksiRemoteDatasource? datasource})
      : _datasource = datasource ?? TransaksiRemoteDatasourceImpl();

  final TransaksiRemoteDatasource _datasource;

  @override
  Future<List<Transaksi>> fetchTransaksi({DateTime? date}) async {
    final models = await _datasource.fetchTransaksi(date: date);
    return models.map((m) => m.toEntity()).toList();
  }
}
