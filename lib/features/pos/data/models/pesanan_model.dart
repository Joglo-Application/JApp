import '../../domain/entities/pesanan.dart';

/// Wire model for the `data` object returned by `POST /pesanan`.
class PesananModel {
  const PesananModel({
    required this.pesananId,
    required this.status,
    required this.total,
  });

  final int pesananId;
  final String status;
  final double total;

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      pesananId: (json['pesananId'] as num).toInt(),
      status: (json['status'] ?? '').toString(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }

  Pesanan toEntity() =>
      Pesanan(pesananId: pesananId, status: status, total: total);
}
