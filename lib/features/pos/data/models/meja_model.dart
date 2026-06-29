/// Wire model for items returned by `GET /meja`.
class MejaModel {
  const MejaModel({
    required this.mejaId,
    required this.nomor,
    this.zona,
    required this.status,
  });

  final int mejaId;
  final String nomor;
  final String? zona;

  /// Backend status: available | occupied | reserved.
  final String status;

  factory MejaModel.fromJson(Map<String, dynamic> json) {
    return MejaModel(
      mejaId: (json['mejaId'] as num).toInt(),
      nomor: (json['nomor'] ?? '').toString(),
      zona: json['zona'] as String?,
      status: (json['status'] ?? 'available').toString(),
    );
  }
}
