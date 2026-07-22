import '../../../../core/network/api_client.dart';

/// Satu baris riwayat absensi milik pengguna yang login.
class RiwayatAbsensi {
  const RiwayatAbsensi({
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  final DateTime tanggal;
  final DateTime jamMasuk;
  final DateTime? jamKeluar;
}

/// Status absensi hari ini + riwayat milik pengguna yang login,
/// hasil `GET /absensi/me`.
class AbsensiSaya {
  const AbsensiSaya({
    required this.sudahMasuk,
    required this.sudahKeluar,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.riwayat,
  });

  final bool sudahMasuk;
  final bool sudahKeluar;
  final DateTime? jamMasuk;
  final DateTime? jamKeluar;
  final List<RiwayatAbsensi> riwayat;
}

abstract interface class AbsensiSayaRemoteDatasource {
  Future<AbsensiSaya> fetchSaya();
  Future<void> absenMasuk();
  Future<void> absenKeluar();
}

class AbsensiSayaRemoteDatasourceImpl implements AbsensiSayaRemoteDatasource {
  AbsensiSayaRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  static DateTime? _parse(Object? iso) =>
      iso == null ? null : DateTime.parse(iso as String).toLocal();

  @override
  Future<AbsensiSaya> fetchSaya() async {
    // GET /absensi/me — status hari ini + riwayat milik sendiri.
    try {
      final res = await _client.dio.get<Map<String, dynamic>>('/absensi/me');
      final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
      final hariIni = data['hariIni'] as Map<String, dynamic>? ?? const {};
      final riwayat = data['riwayat'] as List<dynamic>? ?? const [];
      return AbsensiSaya(
        sudahMasuk: hariIni['sudahMasuk'] == true,
        sudahKeluar: hariIni['sudahKeluar'] == true,
        jamMasuk: _parse(hariIni['jamMasuk']),
        jamKeluar: _parse(hariIni['jamKeluar']),
        riwayat: riwayat.map((e) {
          final j = e as Map<String, dynamic>;
          return RiwayatAbsensi(
            tanggal: DateTime.parse(j['tanggal'] as String),
            jamMasuk: DateTime.parse(j['jamMasuk'] as String).toLocal(),
            jamKeluar: _parse(j['jamKeluar']),
          );
        }).toList(),
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> absenMasuk() async {
    // POST /absensi/masuk — catat absen masuk hari ini.
    try {
      await _client.dio.post<Map<String, dynamic>>('/absensi/masuk');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> absenKeluar() async {
    // POST /absensi/keluar — catat absen keluar hari ini.
    try {
      await _client.dio.post<Map<String, dynamic>>('/absensi/keluar');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
