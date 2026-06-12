import '../entities/inventori_item.dart';

abstract class InventoriRepository {
  Future<List<InventoriItem>> fetchInventori();
}
