/// Wire model for items returned by `GET /member`.
class MemberModel {
  const MemberModel({
    required this.memberId,
    required this.nama,
    this.noTelp,
    this.email,
    required this.poin,
    this.gender,
    this.tanggalLahir,
    this.alamat,
    this.catatan,
  });

  final int memberId;
  final String nama;
  final String? noTelp;
  final String? email;
  final int poin;
  final String? gender;

  /// Format YYYY-MM-DD sesuai kolom `date` di server.
  final String? tanggalLahir;
  final String? alamat;
  final String? catatan;

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      memberId: (json['memberId'] as num).toInt(),
      nama: (json['nama'] ?? '').toString(),
      noTelp: json['noTelp'] as String?,
      email: json['email'] as String?,
      poin: (json['poin'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String?,
      tanggalLahir: json['tanggalLahir'] as String?,
      alamat: json['alamat'] as String?,
      catatan: json['catatan'] as String?,
    );
  }
}

/// Satu baris riwayat transaksi member (`GET /member/:id/transaksi`).
class MemberTransaksiModel {
  const MemberTransaksiModel({
    required this.kodeTransaksi,
    required this.waktu,
    required this.total,
    required this.tipePembayaran,
    required this.items,
    required this.namaKontak,
    required this.isReturned,
  });

  final String kodeTransaksi;
  final DateTime waktu;
  final double total;
  final String tipePembayaran;
  final String items;
  final String namaKontak;
  final bool isReturned;

  factory MemberTransaksiModel.fromJson(Map<String, dynamic> json) {
    return MemberTransaksiModel(
      kodeTransaksi: (json['kodeTransaksi'] ?? '').toString(),
      waktu: DateTime.tryParse(json['waktu'].toString()) ?? DateTime.now(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      tipePembayaran: (json['tipePembayaran'] ?? '').toString(),
      items: (json['items'] ?? '').toString(),
      namaKontak: (json['namaKontak'] ?? '').toString(),
      isReturned: json['isReturned'] == true,
    );
  }
}
