import '../../domain/entities/log_transaksi_entry.dart';
import '../../domain/repositories/log_transaksi_repository.dart';
import '../datasources/log_transaksi_remote_datasource.dart';

class LogTransaksiRepositoryImpl implements LogTransaksiRepository {
  LogTransaksiRepositoryImpl({LogTransaksiRemoteDatasource? datasource})
      : _datasource = datasource ?? LogTransaksiRemoteDatasourceImpl();

  final LogTransaksiRemoteDatasource _datasource;

  @override
  Future<List<LogTransaksiEntry>> fetchLogs({DateTime? date, String? tipe}) =>
      _datasource.fetchLogs(date: date, tipe: tipe);

  @override
  Future<void> createLog({
    required String tipe,
    required String kodeTransaksi,
    required String deskripsi,
  }) =>
      _datasource.createLog(
        tipe: tipe,
        kodeTransaksi: kodeTransaksi,
        deskripsi: deskripsi,
      );
}
