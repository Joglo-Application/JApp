import '../../../../core/network/api_client.dart';

/// Satu baris rekap kehadiran untuk sheet Kehadiran di halaman Pegawai owner.
/// Semua field sudah siap tampil (tanggal & jam dalam bentuk teks).
class OwnerAbsensiRecord {
  const OwnerAbsensiRecord({
    required this.nama,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  final String nama;
  final String tanggal;
  final String jamMasuk;
  final String jamKeluar;
}

class OwnerAbsensiRemoteDatasource {
  OwnerAbsensiRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String _fmtTanggal(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day} ${_bulan[d.month - 1]} ${d.year}';
  }

  static String _fmtJam(String? iso) {
    if (iso == null) return '-';
    final d = DateTime.parse(iso).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  /// GET /absensi?date= — rekap kehadiran semua karyawan (untuk owner/SPV).
  Future<List<OwnerAbsensiRecord>> fetchAbsensi({DateTime? date}) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/absensi',
        queryParameters: {
          'date': ?date?.toIso8601String().substring(0, 10),
        },
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows.map((e) {
        final j = e as Map<String, dynamic>;
        return OwnerAbsensiRecord(
          nama: (j['nama'] ?? '').toString(),
          tanggal: _fmtTanggal(j['tanggal'] as String),
          jamMasuk: _fmtJam(j['jamMasuk'] as String?),
          jamKeluar: _fmtJam(j['jamKeluar'] as String?),
        );
      }).toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
