import '../../../../core/network/api_client.dart';

/// Pilihan produk untuk dokumen stok — membawa id supaya dokumen bisa
/// menunjuk menu/bahan yang tepat, bukan sekadar mencocokkan nama.
class ProdukPilihan {
  const ProdukPilihan({
    required this.id,
    required this.nama,
    this.harga = 0,
    this.stok = 0,
    this.satuan = '',
  });

  final int id;
  final String nama;
  final double harga;

  /// Stok menurut sistem — ditampilkan sebagai pembanding saat stok opname.
  final double stok;

  /// Satuan bahan baku (kg, liter, pcs, …). Kosong untuk menu.
  final String satuan;
}

/// Satu baris item pada dokumen yang dikirim ke server.
class ItemDokumen {
  const ItemDokumen({
    required this.refId,
    required this.jumlah,
    this.harga,
  });

  /// menuId bila sumbernya inventori, bahanId bila stok gudang.
  final int refId;
  final int jumlah;
  final int? harga;
}

/// Ringkasan dokumen stok yang dikembalikan server.
class DokumenStok {
  const DokumenStok({
    required this.id,
    required this.kode,
    required this.tanggal,
    required this.status,
    required this.createdBy,
    required this.produk,
    this.supplier,
    this.catatan,
  });

  final int id;
  final String kode;
  final DateTime tanggal;

  /// `draft`, `posted`, atau `cancelled`.
  final String status;
  final String createdBy;
  final String? supplier;
  final String? catatan;
  final List<Map<String, dynamic>> produk;
}

class StokDokumenRemoteDatasource {
  StokDokumenRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  // ── Sumber pilihan produk ──────────────────────────────────────────────

  /// Menu untuk sumber "Inventori".
  Future<List<ProdukPilihan>> fetchMenus() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/menus',
        // Server membatasi limit maksimal 100; 200 ditolak (422) → daftar kosong.
        queryParameters: {'limit': 100},
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows.map((e) {
        final m = e as Map<String, dynamic>;
        return ProdukPilihan(
          id: (m['menuId'] as num).toInt(),
          nama: (m['namaMenu'] ?? '').toString(),
          harga: (m['harga'] as num?)?.toDouble() ?? 0,
          stok: (m['stok'] as num?)?.toDouble() ?? 0,
        );
      }).toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Bahan baku untuk sumber "Stok Gudang".
  Future<List<ProdukPilihan>> fetchBahanBaku() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/bahan-baku',
        // Server membatasi limit maksimal 100; 200 ditolak (422) → daftar kosong.
        queryParameters: {'limit': 100},
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows.map((e) {
        final m = e as Map<String, dynamic>;
        return ProdukPilihan(
          id: (m['bahanId'] as num).toInt(),
          nama: (m['namaBahan'] ?? '').toString(),
          stok: double.tryParse('${m['stok']}') ?? 0,
          harga: (m['hargaSatuan'] as num?)?.toDouble() ?? 0,
          satuan: (m['satuan'] ?? '').toString(),
        );
      }).toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  // ── Dokumen ────────────────────────────────────────────────────────────

  DokumenStok _toDokumen(Map<String, dynamic> m, String idKey) => DokumenStok(
        id: (m[idKey] as num?)?.toInt() ?? 0,
        kode: (m['kode'] ?? '').toString(),
        tanggal: DateTime.tryParse(m['tanggal'].toString()) ?? DateTime.now(),
        status: (m['status'] ?? 'draft').toString(),
        createdBy: (m['createdBy'] ?? '').toString(),
        supplier: m['supplier'] as String?,
        catatan: m['catatan'] as String?,
        produk: (m['produk'] as List<dynamic>? ?? const [])
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );

  Future<List<DokumenStok>> _list(String path, String idKey) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(path);
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => _toDokumen(e as Map<String, dynamic>, idKey))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<List<DokumenStok>> fetchStokMasuk() => _list('/stok-masuk', 'stokMasukId');
  Future<List<DokumenStok>> fetchStokKeluar() => _list('/stok-keluar', 'stokKeluarId');
  Future<List<DokumenStok>> fetchStokOpname() => _list('/stok-opname', 'opnameId');
  Future<List<DokumenStok>> fetchProduksiStok() => _list('/produksi-stok', 'produksiId');

  /// Membuat dokumen stok masuk. Kode dokumennya ditentukan server.
  Future<void> createStokMasuk({
    required List<ItemDokumen> items,
    required List<String> sumber,
    String? supplier,
    String? catatan,
    required bool langsungPosting,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/stok-masuk',
        data: {
          if (supplier != null && supplier.isNotEmpty) 'supplier': supplier,
          if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
          'langsungPosting': langsungPosting,
          'items': [
            for (var i = 0; i < items.length; i++)
              {
                'sumber': sumber[i],
                if (sumber[i] == 'inventori')
                  'menuId': items[i].refId
                else
                  'bahanId': items[i].refId,
                'jumlah': items[i].jumlah,
              },
          ],
        },
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Nama bahan pada resep sebuah menu. Diambil hanya untuk produk yang
  /// benar-benar dipilih — memuatnya untuk seluruh daftar berarti satu
  /// permintaan per menu.
  Future<List<String>> fetchResep(int menuId) async {
    try {
      final res =
          await _client.dio.get<Map<String, dynamic>>('/menus/$menuId/resep');
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => ((e as Map<String, dynamic>)['namaBahan'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Membuat dokumen produksi stok. Itemnya selalu berupa menu.
  Future<void> createProduksiStok({
    required List<ItemDokumen> items,
    String? catatan,
    required bool langsungPosting,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/produksi-stok',
        data: {
          if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
          'langsungPosting': langsungPosting,
          'items': [
            for (final it in items) {'menuId': it.refId, 'jumlah': it.jumlah},
          ],
        },
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Membuat dokumen stok opname. Satu dokumen boleh memuat bahan baku
  /// maupun produk jadi. Stok sistem tidak dikirim — server merekamnya sendiri
  /// saat dokumen dibuat agar selisihnya dihitung dari angka yang otoritatif.
  Future<void> createStokOpname({
    required List<ItemDokumen> items,
    required List<String> sumber,
    required List<double> stokFisik,
    String? catatan,
    required bool langsungPosting,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/stok-opname',
        data: {
          if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
          'langsungPosting': langsungPosting,
          'items': [
            for (var i = 0; i < items.length; i++)
              {
                'sumber': sumber[i],
                if (sumber[i] == 'inventori')
                  'menuId': items[i].refId
                else
                  'bahanId': items[i].refId,
                'stokFisik': stokFisik[i],
              },
          ],
        },
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Membuat dokumen stok keluar. Itemnya berupa produk jadi (menu), sesuai
  /// pemilih produk di layar Kelola Stok.
  Future<void> createStokKeluar({
    required List<ItemDokumen> items,
    String? catatan,
    required bool langsungPosting,
  }) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/stok-keluar',
        data: {
          if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
          'langsungPosting': langsungPosting,
          'items': [
            for (final it in items)
              {
                'sumber': 'inventori',
                'menuId': it.refId,
                'jumlah': it.jumlah,
                'harga': it.harga ?? 0,
              },
          ],
        },
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
