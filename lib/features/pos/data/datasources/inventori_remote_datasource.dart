import '../../../../core/network/api_client.dart';
import '../models/inventori_item_model.dart';

abstract class InventoriRemoteDatasource {
  Future<List<InventoriItemModel>> fetchInventori();
}

class InventoriRemoteDatasourceImpl implements InventoriRemoteDatasource {
  InventoriRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  // ignore: unused_field — retained for when GET /inventori is wired up.
  final ApiClient _client;

  @override
  Future<List<InventoriItemModel>> fetchInventori() async {
    // TODO: replace with real API call when GET /inventori endpoint is available.
    await Future.delayed(const Duration(milliseconds: 400));
    return _kStubData;
  }
}

// ── Stub data (remove once real endpoint is wired) ────────────────────────────

final _kStubData = <InventoriItemModel>[
  InventoriItemModel.fromJson({
    'id': 'INV-001',
    'nama': 'Burger Sapi',
    'kategori': 'Makanan',
    'qtyStok': 32,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
  InventoriItemModel.fromJson({
    'id': 'INV-002',
    'nama': 'Bakmi Udang',
    'kategori': 'Makanan',
    'qtyStok': 25,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
  InventoriItemModel.fromJson({
    'id': 'INV-003',
    'nama': 'Lemon Squash',
    'kategori': 'Minuman',
    'qtyStok': 25,
    'qtyTahan': 8,
    'imageUrl': null,
  }),
  InventoriItemModel.fromJson({
    'id': 'INV-004',
    'nama': 'Americano',
    'kategori': 'Kopi',
    'qtyStok': 23,
    'qtyTahan': 5,
    'imageUrl': null,
  }),
  InventoriItemModel.fromJson({
    'id': 'INV-005',
    'nama': 'Tahu Walik',
    'kategori': 'Snack',
    'qtyStok': 8,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
];
