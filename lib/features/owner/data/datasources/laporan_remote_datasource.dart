import '../../../../core/network/api_client.dart';

/// Ringkasan penutupan penjualan (`GET /laporan/ringkasan`).
class LaporanRingkasan {
  const LaporanRingkasan({
    required this.pendapatan,
    required this.pengeluaran,
    required this.retur,
    required this.pendapatanBersih,
    required this.subtotal,
    required this.biayaLayanan,
    required this.pajak,
    required this.diskon,
    required this.pesananDiterima,
    required this.pesananDiretur,
    required this.pesananDibatalkan,
    required this.poinTerkumpul,
    required this.poinDitukar,
  });

  final double pendapatan;
  final double pengeluaran;
  final double retur;
  final double pendapatanBersih;
  final double subtotal;
  final double biayaLayanan;
  final double pajak;
  final double diskon;
  final int pesananDiterima;
  final int pesananDiretur;
  final int pesananDibatalkan;
  final int poinTerkumpul;
  final int poinDitukar;

  static double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;
  static int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

  factory LaporanRingkasan.fromJson(Map<String, dynamic> json) {
    final rincian = json['rincian'] as Map<String, dynamic>? ?? const {};
    final pesanan = json['pesanan'] as Map<String, dynamic>? ?? const {};
    final loyalty = json['loyalty'] as Map<String, dynamic>? ?? const {};
    return LaporanRingkasan(
      pendapatan: _d(json['pendapatan']),
      pengeluaran: _d(json['pengeluaran']),
      retur: _d(json['retur']),
      pendapatanBersih: _d(json['pendapatanBersih']),
      subtotal: _d(rincian['subtotal']),
      biayaLayanan: _d(rincian['biayaLayanan']),
      pajak: _d(rincian['pajak']),
      diskon: _d(rincian['diskon']),
      pesananDiterima: _i(pesanan['diterima']),
      pesananDiretur: _i(pesanan['diretur']),
      pesananDibatalkan: _i(pesanan['dibatalkan']),
      poinTerkumpul: _i(loyalty['poinTerkumpul']),
      poinDitukar: _i(loyalty['poinDitukar']),
    );
  }

  static const kosong = LaporanRingkasan(
    pendapatan: 0,
    pengeluaran: 0,
    retur: 0,
    pendapatanBersih: 0,
    subtotal: 0,
    biayaLayanan: 0,
    pajak: 0,
    diskon: 0,
    pesananDiterima: 0,
    pesananDiretur: 0,
    pesananDibatalkan: 0,
    poinTerkumpul: 0,
    poinDitukar: 0,
  );
}

class LaporanProdukItem {
  const LaporanProdukItem({
    required this.nama,
    required this.kategori,
    required this.qty,
    required this.omzet,
  });

  final String nama;
  final String kategori;
  final int qty;
  final double omzet;

  factory LaporanProdukItem.fromJson(Map<String, dynamic> json) =>
      LaporanProdukItem(
        nama: (json['nama'] ?? '').toString(),
        kategori: (json['kategori'] ?? '').toString(),
        qty: (json['qty'] as num?)?.toInt() ?? 0,
        omzet: (json['omzet'] as num?)?.toDouble() ?? 0,
      );
}

class LaporanKategoriItem {
  const LaporanKategoriItem({
    required this.kategori,
    required this.qty,
    required this.omzet,
  });

  final String kategori;
  final int qty;
  final double omzet;

  factory LaporanKategoriItem.fromJson(Map<String, dynamic> json) =>
      LaporanKategoriItem(
        kategori: (json['kategori'] ?? '').toString(),
        qty: (json['qty'] as num?)?.toInt() ?? 0,
        omzet: (json['omzet'] as num?)?.toDouble() ?? 0,
      );
}

class LaporanProduk {
  const LaporanProduk({required this.items, required this.kategori});
  final List<LaporanProdukItem> items;
  final List<LaporanKategoriItem> kategori;
}

class LaporanPembayaranItem {
  const LaporanPembayaranItem({
    required this.metode,
    required this.jumlahTransaksi,
    required this.total,
  });

  final String metode;
  final int jumlahTransaksi;
  final double total;

  factory LaporanPembayaranItem.fromJson(Map<String, dynamic> json) =>
      LaporanPembayaranItem(
        metode: (json['metode'] ?? '').toString(),
        jumlahTransaksi: (json['jumlahTransaksi'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
      );
}

class LaporanGuestItem {
  const LaporanGuestItem({required this.zona, required this.jumlahTamu});
  final String zona;
  final int jumlahTamu;

  factory LaporanGuestItem.fromJson(Map<String, dynamic> json) =>
      LaporanGuestItem(
        zona: (json['zona'] ?? '').toString(),
        jumlahTamu: (json['jumlahTamu'] as num?)?.toInt() ?? 0,
      );
}

class LaporanGuest {
  const LaporanGuest({required this.items, required this.totalTamu});
  final List<LaporanGuestItem> items;
  final int totalTamu;
}

/// Satu titik pada grafik harian dashboard.
class LaporanHarian {
  const LaporanHarian({
    required this.tanggal,
    required this.pendapatan,
    required this.pengeluaran,
  });

  final DateTime tanggal;
  final double pendapatan;
  final double pengeluaran;

  factory LaporanHarian.fromJson(Map<String, dynamic> json) => LaporanHarian(
        tanggal:
            DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now(),
        pendapatan: (json['pendapatan'] as num?)?.toDouble() ?? 0,
        pengeluaran: (json['pengeluaran'] as num?)?.toDouble() ?? 0,
      );
}

class LaporanDashboard {
  const LaporanDashboard({
    required this.ringkasan,
    required this.harian,
    required this.topProduk,
    required this.topKategori,
  });

  final LaporanRingkasan ringkasan;
  final List<LaporanHarian> harian;
  final List<LaporanProdukItem> topProduk;
  final List<LaporanKategoriItem> topKategori;
}

class LaporanRemoteDatasource {
  LaporanRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Map<String, dynamic> _rentang(DateTime? start, DateTime? end) => {
        if (start != null) 'start': start.toIso8601String().substring(0, 10),
        if (end != null) 'end': end.toIso8601String().substring(0, 10),
      };

  Future<Map<String, dynamic>> _get(
    String path,
    DateTime? start,
    DateTime? end,
  ) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: _rentang(start, end),
      );
      return res.data?['data'] as Map<String, dynamic>? ?? const {};
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<LaporanRingkasan> fetchRingkasan({DateTime? start, DateTime? end}) async {
    return LaporanRingkasan.fromJson(await _get('/laporan/ringkasan', start, end));
  }

  Future<LaporanProduk> fetchProduk({DateTime? start, DateTime? end}) async {
    final data = await _get('/laporan/produk', start, end);
    return LaporanProduk(
      items: (data['items'] as List<dynamic>? ?? const [])
          .map((e) => LaporanProdukItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      kategori: (data['kategori'] as List<dynamic>? ?? const [])
          .map((e) => LaporanKategoriItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<LaporanPembayaranItem>> fetchPembayaran({
    DateTime? start,
    DateTime? end,
  }) async {
    final data = await _get('/laporan/pembayaran', start, end);
    return (data['items'] as List<dynamic>? ?? const [])
        .map((e) => LaporanPembayaranItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LaporanGuest> fetchGuest({DateTime? start, DateTime? end}) async {
    final data = await _get('/laporan/guest', start, end);
    return LaporanGuest(
      items: (data['items'] as List<dynamic>? ?? const [])
          .map((e) => LaporanGuestItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalTamu: (data['totalTamu'] as num?)?.toInt() ?? 0,
    );
  }

  /// Satu panggilan untuk seluruh dashboard — menggantikan tujuh permintaan
  /// `GET /transaksi` paralel yang sebelumnya dipakai hanya untuk grafik.
  Future<LaporanDashboard> fetchDashboard({DateTime? start, DateTime? end}) async {
    final data = await _get('/laporan/dashboard', start, end);
    return LaporanDashboard(
      ringkasan: LaporanRingkasan.fromJson(
        data['ringkasan'] as Map<String, dynamic>? ?? const {},
      ),
      harian: (data['harian'] as List<dynamic>? ?? const [])
          .map((e) => LaporanHarian.fromJson(e as Map<String, dynamic>))
          .toList(),
      topProduk: (data['topProduk'] as List<dynamic>? ?? const [])
          .map((e) => LaporanProdukItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      topKategori: (data['topKategori'] as List<dynamic>? ?? const [])
          .map((e) => LaporanKategoriItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
