import '../../../../core/network/api_client.dart';

/// Satu area denah beserta nomor meja di dalamnya.
class LayoutArea {
  const LayoutArea({
    required this.areaId,
    required this.nama,
    required this.mejaNomor,
  });

  final int areaId;
  final String nama;
  final List<String> mejaNomor;
}

/// Menggabungkan `/area` dan `/meja` menjadi bentuk denah yang dipakai layar
/// Pengaturan > Layout Toko: satu area berisi banyak meja.
class LayoutTokoRemoteDatasource {
  LayoutTokoRemoteDatasource({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<LayoutArea>> fetchLayouts() async {
    try {
      final areaRes = await _client.dio.get<Map<String, dynamic>>('/area');
      final mejaRes = await _client.dio.get<Map<String, dynamic>>(
        '/meja',
        queryParameters: {'limit': 100},
      );

      final areas = areaRes.data?['data'] as List<dynamic>? ?? const [];
      final mejas = mejaRes.data?['data'] as List<dynamic>? ?? const [];

      return areas.map((a) {
        final area = a as Map<String, dynamic>;
        final areaId = (area['areaId'] as num).toInt();
        return LayoutArea(
          areaId: areaId,
          nama: (area['nama'] ?? '').toString(),
          mejaNomor: mejas
              .map((m) => m as Map<String, dynamic>)
              .where((m) => (m['areaId'] as num?)?.toInt() == areaId)
              .map((m) => (m['nomor'] ?? '').toString())
              .toList(),
        );
      }).toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Mengambil seluruh meja beserta id-nya, dipakai untuk mencocokkan nomor.
  Future<Map<String, int>> _idMejaPerNomor() async {
    final res = await _client.dio.get<Map<String, dynamic>>(
      '/meja',
      queryParameters: {'limit': 100},
    );
    final rows = res.data?['data'] as List<dynamic>? ?? const [];
    return {
      for (final r in rows.map((e) => e as Map<String, dynamic>))
        (r['nomor'] ?? '').toString(): (r['mejaId'] as num).toInt(),
    };
  }

  /// Memasukkan sebuah nomor meja ke dalam area.
  ///
  /// Bila nomornya sudah terdaftar, mejanya cukup dikaitkan ke area — bukan
  /// dibuat ulang, karena server menolak nomor ganda. Ini yang terjadi pada
  /// meja yang sudah ada sebelum denah mulai dipakai.
  Future<void> _kaitkanMeja(
    String nomor,
    int areaId,
    Map<String, int> idPerNomor,
  ) async {
    final mejaId = idPerNomor[nomor];
    if (mejaId != null) {
      await _client.dio.patch<Map<String, dynamic>>(
        '/meja/$mejaId',
        data: {'areaId': areaId},
      );
      return;
    }
    await _client.dio.post<Map<String, dynamic>>(
      '/meja',
      data: {'nomor': nomor, 'areaId': areaId},
    );
  }

  /// Membuat area lalu mengaitkan meja-mejanya.
  Future<void> createLayout({
    required String nama,
    required List<String> mejaNomor,
    required int urutan,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/area',
        data: {'nama': nama, 'urutan': urutan},
      );
      final areaId =
          ((res.data?['data'] as Map<String, dynamic>?)?['areaId'] as num?)
              ?.toInt();
      if (areaId == null) return;

      final idPerNomor = await _idMejaPerNomor();
      for (final nomor in mejaNomor) {
        await _kaitkanMeja(nomor, areaId, idPerNomor);
      }
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Menyimpan perubahan denah: nama area diperbarui, lalu daftar mejanya
  /// dibandingkan. Yang bertambah dikaitkan ke area, yang hilang dilepas
  /// kaitannya — bukan dihapus, karena "keluarkan dari denah" jauh lebih
  /// ringan maksudnya daripada "hapus mejanya". Meja yang tetap ada tidak
  /// disentuh supaya statusnya tidak berubah.
  Future<void> updateLayout({
    required int areaId,
    required String nama,
    required List<String> mejaNomorBaru,
    required List<String> mejaNomorLama,
  }) async {
    try {
      await _client.dio.patch<Map<String, dynamic>>(
        '/area/$areaId',
        data: {'nama': nama},
      );

      final idPerNomor = await _idMejaPerNomor();

      for (final nomor in mejaNomorBaru.where(
        (n) => !mejaNomorLama.contains(n),
      )) {
        await _kaitkanMeja(nomor, areaId, idPerNomor);
      }

      for (final nomor in mejaNomorLama.where(
        (n) => !mejaNomorBaru.contains(n),
      )) {
        final mejaId = idPerNomor[nomor];
        if (mejaId == null) continue;
        await _client.dio.patch<Map<String, dynamic>>(
          '/meja/$mejaId',
          data: {'areaId': null},
        );
      }
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Menghapus area. Mejanya tidak ikut terhapus — server melepas kaitannya
  /// (area_id jadi null), supaya riwayat pesanan pada meja itu tetap utuh.
  Future<void> deleteLayout(int areaId) async {
    try {
      await _client.dio.delete<Map<String, dynamic>>('/area/$areaId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
