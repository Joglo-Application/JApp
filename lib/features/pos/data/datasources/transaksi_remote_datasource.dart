import '../../../../core/network/api_client.dart';
import '../models/transaksi_model.dart';

abstract class TransaksiRemoteDatasource {
  Future<List<TransaksiModel>> fetchTransaksi({DateTime? date});
}

class TransaksiRemoteDatasourceImpl implements TransaksiRemoteDatasource {
  TransaksiRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  // ignore: unused_field — retained for when GET /transaksi is wired up.
  final ApiClient _client;

  @override
  Future<List<TransaksiModel>> fetchTransaksi({DateTime? date}) async {
    // TODO: replace with real API call when GET /transaksi endpoint is available.
    // try {
    //   final dateStr = (date ?? DateTime.now()).toIso8601String().substring(0, 10);
    //   final res = await _client.dio.get<Map<String, dynamic>>(
    //     '/transaksi',
    //     queryParameters: {'date': dateStr},
    //   );
    //   final rows = res.data!['data'] as List<dynamic>;
    //   return rows
    //       .map((e) => TransaksiModel.fromJson(e as Map<String, dynamic>))
    //       .toList();
    // } catch (e) {
    //   throw _client.toApiException(e);
    // }
    await Future.delayed(const Duration(milliseconds: 400));
    return _kStubData;
  }
}

// ── Stub data (remove once real endpoint is wired) ────────────────────────────

final _kStubData = <TransaksiModel>[
  TransaksiModel.fromJson({
    'kodeTransaksi': 'TRX-0001',
    'waktu': '2026-06-12T09:15:00',
    'namaStaff': 'Budi Santoso',
    'namaKontak': 'Ahmad',
    'tipePembayaran': 'TUNAI',
    'nominalPembayaran': 46800,
    'subtotal': 45000,
    'biayaLayananPct': 2,
    'biayaLayanan': 900,
    'pajakTokoPct': 2,
    'pajakToko': 900,
    'items': [
      {'nama': 'Nasi Goreng Special', 'hargaSatuan': 25000, 'qty': 1, 'total': 25000},
      {'nama': 'Es Teh Manis', 'hargaSatuan': 10000, 'qty': 2, 'total': 20000},
    ],
    'total': 46800,
  }),
  TransaksiModel.fromJson({
    'kodeTransaksi': 'TRX-0002',
    'waktu': '2026-06-12T10:30:00',
    'namaStaff': 'Siti Rahayu',
    'namaKontak': '',
    'tipePembayaran': 'QRIS',
    'nominalPembayaran': 83200,
    'subtotal': 80000,
    'biayaLayananPct': 2,
    'biayaLayanan': 1600,
    'pajakTokoPct': 2,
    'pajakToko': 1600,
    'items': [
      {'nama': 'Mie Goreng', 'hargaSatuan': 15000, 'qty': 4, 'total': 60000},
      {'nama': 'Jus Jeruk', 'hargaSatuan': 10000, 'qty': 2, 'total': 20000},
    ],
    'total': 83200,
  }),
  TransaksiModel.fromJson({
    'kodeTransaksi': 'TRX-0003',
    'waktu': '2026-06-12T12:45:00',
    'namaStaff': 'Budi Santoso',
    'namaKontak': 'Dewi',
    'tipePembayaran': 'Transfer',
    'nominalPembayaran': 120000,
    'subtotal': 115000,
    'biayaLayananPct': 2,
    'biayaLayanan': 2300,
    'pajakTokoPct': 2,
    'pajakToko': 2300,
    'items': [
      {'nama': 'Ayam Bakar', 'hargaSatuan': 35000, 'qty': 2, 'total': 70000},
      {'nama': 'Nasi Putih', 'hargaSatuan': 5000, 'qty': 3, 'total': 15000},
      {'nama': 'Es Kelapa Muda', 'hargaSatuan': 15000, 'qty': 2, 'total': 30000},
    ],
    'total': 120000,
  }),
];
