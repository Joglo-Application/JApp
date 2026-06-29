/// Wire model for items returned by `GET /member`.
class MemberModel {
  const MemberModel({
    required this.memberId,
    required this.nama,
    this.noTelp,
    this.email,
    required this.poin,
  });

  final int memberId;
  final String nama;
  final String? noTelp;
  final String? email;
  final int poin;

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      memberId: (json['memberId'] as num).toInt(),
      nama: (json['nama'] ?? '').toString(),
      noTelp: json['noTelp'] as String?,
      email: json['email'] as String?,
      poin: (json['poin'] as num?)?.toInt() ?? 0,
    );
  }
}
