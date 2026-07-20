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

  /// Membuat area lalu meja-mejanya. Meja dibuat setelah areanya ada karena
  /// masing-masing perlu menunjuk areaId.
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

      for (final nomor in mejaNomor) {
        await _client.dio.post<Map<String, dynamic>>(
          '/meja',
          data: {'nomor': nomor, 'areaId': areaId},
        );
      }
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Menyimpan perubahan denah: nama area diperbarui, lalu daftar mejanya
  /// dibandingkan — yang baru dibuat, yang hilang dihapus. Meja yang tetap ada
  /// sengaja tidak disentuh supaya statusnya (terpakai/dipesan) tidak hilang.
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

      final tambah = mejaNomorBaru.where((n) => !mejaNomorLama.contains(n));
      for (final nomor in tambah) {
        await _client.dio.post<Map<String, dynamic>>(
          '/meja',
          data: {'nomor': nomor, 'areaId': areaId},
        );
      }

      final hapus = mejaNomorLama.where((n) => !mejaNomorBaru.contains(n));
      if (hapus.isEmpty) return;

      final mejaRes = await _client.dio.get<Map<String, dynamic>>(
        '/meja',
        queryParameters: {'limit': 100},
      );
      final mejas = (mejaRes.data?['data'] as List<dynamic>? ?? const [])
          .map((m) => m as Map<String, dynamic>);
      for (final nomor in hapus) {
        final target = mejas.where((m) => (m['nomor'] ?? '') == nomor);
        if (target.isEmpty) continue;
        await _client.dio.delete<Map<String, dynamic>>(
          '/meja/${(target.first['mejaId'] as num).toInt()}',
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
