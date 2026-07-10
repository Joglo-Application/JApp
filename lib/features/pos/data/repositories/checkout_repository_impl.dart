import '../../domain/entities/create_pesanan_params.dart';
import '../../domain/entities/pembayaran.dart';
import '../../domain/entities/pesanan.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_datasource.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl({CheckoutRemoteDatasource? datasource})
      : _datasource = datasource ?? CheckoutRemoteDatasourceImpl();

  final CheckoutRemoteDatasource _datasource;

  @override
  Future<Pesanan> createPesanan(CreatePesananParams params) async {
    final model = await _datasource.createPesanan(params);
    return model.toEntity();
  }

  @override
  Future<Pembayaran> createPembayaran({
    required int pesananId,
    required String metode,
    required int jumlahBayar,
  }) async {
    final model = await _datasource.createPembayaran(
      pesananId: pesananId,
      metode: metode,
      jumlahBayar: jumlahBayar,
    );
    return model.toEntity();
  }

  @override
  Future<void> cancelPesanan(int pesananId) =>
      _datasource.cancelPesanan(pesananId);
}
