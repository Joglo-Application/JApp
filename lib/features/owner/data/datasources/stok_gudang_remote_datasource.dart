import '../../../../core/network/api_client.dart';
import '../models/stok_gudang_item_model.dart';

abstract class StokGudangRemoteDatasource {
  Future<List<StokGudangItemModel>> fetchStokGudang();
}

class StokGudangRemoteDatasourceImpl implements StokGudangRemoteDatasource {
  StokGudangRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  // ignore: unused_field — retained for when GET /stok-gudang is wired up.
  final ApiClient _client;

  @override
  Future<List<StokGudangItemModel>> fetchStokGudang() async {
    // TODO: replace with real API call when GET /stok-gudang endpoint is available.
    await Future.delayed(const Duration(milliseconds: 400));
    return _kStubData;
  }
}

// ── Stub data (remove once real endpoint is wired) ────────────────────────────

final _kStubData = <StokGudangItemModel>[
  StokGudangItemModel.fromJson({
    'id': 'STK-001',
    'nama': 'Beras',
    'kategori': 'Cabe',
    'unitProduk': 'Kilogram (100)',
    'qtyStok': 1000,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
  StokGudangItemModel.fromJson({
    'id': 'STK-002',
    'nama': 'Air Galon',
    'kategori': 'Saos',
    'unitProduk': 'Liter (5)',
    'qtyStok': 500,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
  StokGudangItemModel.fromJson({
    'id': 'STK-003',
    'nama': 'Telur',
    'kategori': 'Cabe',
    'unitProduk': 'Butir (1)',
    'qtyStok': 100,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
  StokGudangItemModel.fromJson({
    'id': 'STK-004',
    'nama': 'Tepung Terigu',
    'kategori': 'Saos',
    'unitProduk': 'Gram (5)',
    'qtyStok': 600,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
  StokGudangItemModel.fromJson({
    'id': 'STK-005',
    'nama': 'Daging Ayam Fillet',
    'kategori': 'Frozen Food',
    'unitProduk': 'Gram (10)',
    'qtyStok': 200,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
  StokGudangItemModel.fromJson({
    'id': 'STK-006',
    'nama': 'Kentang',
    'kategori': 'Cabe',
    'unitProduk': 'Gram (50)',
    'qtyStok': 700,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
];
