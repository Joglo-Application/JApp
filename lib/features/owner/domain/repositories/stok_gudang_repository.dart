import '../entities/stok_gudang_item.dart';

abstract class StokGudangRepository {
  Future<List<StokGudangItem>> fetchStokGudang();
}
