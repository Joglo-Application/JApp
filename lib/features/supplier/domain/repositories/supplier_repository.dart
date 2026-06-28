import '../entities/supplier_item.dart';

abstract class SupplierRepository {
  Future<List<SupplierItem>> fetchItems();
}
