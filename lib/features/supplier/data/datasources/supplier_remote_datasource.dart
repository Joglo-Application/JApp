import '../../../../core/network/api_client.dart';
import '../models/supplier_item_model.dart';

abstract class SupplierRemoteDatasource {
  Future<List<SupplierItemModel>> fetchItems();
}

class SupplierRemoteDatasourceImpl implements SupplierRemoteDatasource {
  SupplierRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  // ignore: unused_field — retained for when GET /supplier/items is wired up.
  final ApiClient _client;

  @override
  Future<List<SupplierItemModel>> fetchItems() async {
    // TODO: replace with real API call when GET /supplier/items endpoint is available.
    await Future.delayed(const Duration(milliseconds: 400));
    return _kStubData;
  }
}

// ── Stub data ─────────────────────────────────────────────────────────────────

final _kStubData = <SupplierItemModel>[
  SupplierItemModel.fromJson({
    'id': 'SUP-001',
    'nama': 'Gula Pasir',
    'kategori': 'Bahan Dasar',
    'unitProduk': 'Gram (10)',
    'qtyStok': 4,
    'qtyTahan': 10,
    'imageUrl': null,
  }),
  SupplierItemModel.fromJson({
    'id': 'SUP-002',
    'nama': 'Kecap Manis',
    'kategori': 'Bumbu',
    'unitProduk': 'Liter (1)',
    'qtyStok': 14,
    'qtyTahan': 20,
    'imageUrl': null,
  }),
];
