import '../../domain/entities/pembayaran.dart';

/// Wire model for the `data` object returned by `POST /pembayaran`.
class PembayaranModel {
  const PembayaranModel({
    required this.pembayaranId,
    required this.pesananId,
    required this.metode,
    required this.jumlahBayar,
    required this.kembalian,
  });

  final int pembayaranId;
  final int pesananId;
  final String metode;
  final double jumlahBayar;
  final double kembalian;

  factory PembayaranModel.fromJson(Map<String, dynamic> json) {
    return PembayaranModel(
      pembayaranId: (json['pembayaranId'] as num).toInt(),
      pesananId: (json['pesananId'] as num).toInt(),
      metode: (json['metode'] ?? '').toString(),
      jumlahBayar: (json['jumlahBayar'] as num?)?.toDouble() ?? 0,
      kembalian: (json['kembalian'] as num?)?.toDouble() ?? 0,
    );
  }

  Pembayaran toEntity() => Pembayaran(
        pembayaranId: pembayaranId,
        pesananId: pesananId,
        metode: metode,
        jumlahBayar: jumlahBayar,
        kembalian: kembalian,
      );
}
