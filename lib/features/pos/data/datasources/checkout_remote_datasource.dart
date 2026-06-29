import '../../../../core/network/api_client.dart';
import '../../domain/entities/create_pesanan_params.dart';
import '../models/loaded_pesanan_model.dart';
import '../models/pembayaran_model.dart';
import '../models/pesanan_model.dart';

abstract class CheckoutRemoteDatasource {
  Future<PesananModel> createPesanan(CreatePesananParams params);

  Future<PembayaranModel> createPembayaran({
    required int pesananId,
    required String metode,
    required int jumlahBayar,
  });

  /// Pesanan pending yang terparkir di sebuah meja (untuk "Lihat Pesanan").
  /// Mengembalikan `null` bila meja belum punya pesanan aktif.
  Future<LoadedPesanan?> fetchActivePesananForMeja(int mejaId);

  /// Jumlah pesanan pending per meja (mejaId → jumlah), untuk badge "Transaksi".
  Future<Map<int, int>> fetchPendingCountByMeja();

  /// Daftar draft "held" (fitur Pending) beserta item-nya.
  Future<List<LoadedPesanan>> fetchHeldOrders();

  /// Hapus draft held (saat di-Pilih/Gabung kembali ke POS).
  Future<void> deleteHeldOrder(int pesananId);
}

class CheckoutRemoteDatasourceImpl implements CheckoutRemoteDatasource {
  CheckoutRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<PesananModel> createPesanan(CreatePesananParams params) async {
    // POST /pesanan — transaksi penjualan POS (auto-deduct stok).
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/pesanan',
        data: _pesananBody(params),
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      return PesananModel.fromJson(data);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<PembayaranModel> createPembayaran({
    required int pesananId,
    required String metode,
    required int jumlahBayar,
  }) async {
    // POST /pembayaran — validates jumlahBayar >= total, computes change,
    // marks the order completed (atomic).
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/pembayaran',
        data: {
          'pesananId': pesananId,
          'metode': metode,
          'jumlahBayar': jumlahBayar,
        },
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      return PembayaranModel.fromJson(data);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<LoadedPesanan?> fetchActivePesananForMeja(int mejaId) async {
    try {
      // 1) Cari pesanan pending milik meja ini.
      final list = await _client.dio.get<Map<String, dynamic>>(
        '/pesanan',
        queryParameters: {'mejaId': mejaId, 'status': 'in_progress', 'limit': 1},
      );
      final rows = list.data?['data'] as List<dynamic>? ?? const [];
      if (rows.isEmpty) return null;
      final pesananId = ((rows.first as Map)['pesananId'] as num).toInt();

      // 2) Ambil detail beserta item-nya.
      final detail =
          await _client.dio.get<Map<String, dynamic>>('/pesanan/$pesananId');
      final data = detail.data!['data'] as Map<String, dynamic>;
      return LoadedPesanan.fromJson(data);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<Map<int, int>> fetchPendingCountByMeja() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/pesanan',
        queryParameters: {'status': 'in_progress', 'limit': 100},
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      final counts = <int, int>{};
      for (final r in rows) {
        final mid = (r as Map)['mejaId'];
        if (mid is num) {
          counts[mid.toInt()] = (counts[mid.toInt()] ?? 0) + 1;
        }
      }
      return counts;
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Map<String, dynamic> _pesananBody(CreatePesananParams p) {
    final body = <String, dynamic>{
      'items': p.items.map((i) {
        final m = <String, dynamic>{'jumlah': i.jumlah};
        if (i.menuId != null) m['menuId'] = i.menuId;
        if (i.namaCustom != null) m['namaCustom'] = i.namaCustom;
        if (i.hargaSatuan != null) m['hargaSatuan'] = i.hargaSatuan;
        if (i.diskon > 0) m['diskon'] = i.diskon;
        if (i.catatan != null && i.catatan!.isNotEmpty) m['catatan'] = i.catatan;
        return m;
      }).toList(),
    };
    if (p.customerNama != null) body['customerNama'] = p.customerNama;
    if (p.orderType != null) body['orderType'] = p.orderType;
    if (p.catatan != null) body['catatan'] = p.catatan;
    if (p.mejaId != null) body['mejaId'] = p.mejaId;
    if (p.memberId != null) body['memberId'] = p.memberId;
    if (p.diskon != null) {
      body['diskon'] = {
        'tipe': p.diskon!.tipe,
        'nilai': p.diskon!.nilai,
        if (p.diskon!.promoNama != null) 'promoNama': p.diskon!.promoNama,
      };
    }
    if (p.hold) body['hold'] = true;
    return body;
  }

  @override
  Future<List<LoadedPesanan>> fetchHeldOrders() async {
    try {
      final list = await _client.dio.get<Map<String, dynamic>>(
        '/pesanan',
        queryParameters: {'status': 'pending', 'limit': 100},
      );
      final rows = list.data?['data'] as List<dynamic>? ?? const [];
      // Ambil detail (beserta item) tiap draft.
      final results = await Future.wait(rows.map((r) async {
        final id = ((r as Map)['pesananId'] as num).toInt();
        final detail =
            await _client.dio.get<Map<String, dynamic>>('/pesanan/$id');
        return LoadedPesanan.fromJson(detail.data!['data'] as Map<String, dynamic>);
      }));
      return results;
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> deleteHeldOrder(int pesananId) async {
    try {
      await _client.dio.delete<Map<String, dynamic>>('/pesanan/$pesananId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
