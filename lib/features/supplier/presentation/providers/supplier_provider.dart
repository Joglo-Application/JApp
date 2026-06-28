import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../domain/entities/supplier_item.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/usecases/fetch_supplier_items_usecase.dart';

class SupplierProvider extends ChangeNotifier {
  SupplierProvider({SupplierRepository? repository}) {
    final repo = repository ?? SupplierRepositoryImpl();
    _fetchItems = FetchSupplierItemsUseCase(repo);
  }

  late final FetchSupplierItemsUseCase _fetchItems;

  bool _isLoading = false;
  String? _error;
  List<SupplierItem> _all = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SupplierItem> get items => _all;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _fetchItems();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat data. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addItem(SupplierItem item) {
    _all = [item, ..._all];
    notifyListeners();
  }

  void removeItem(String id) {
    _all = _all.where((item) => item.id != id).toList();
    notifyListeners();
  }

  void updateItem(SupplierItem updated) {
    _all = [for (final item in _all) if (item.id == updated.id) updated else item];
    notifyListeners();
  }
}
