import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/stok_gudang_repository_impl.dart';
import '../../domain/entities/stok_gudang_item.dart';
import '../../domain/repositories/stok_gudang_repository.dart';
import '../../domain/usecases/fetch_stok_gudang_usecase.dart';

class StokGudangProvider extends ChangeNotifier {
  StokGudangProvider({StokGudangRepository? repository}) {
    final repo = repository ?? StokGudangRepositoryImpl();
    _fetchStokGudang = FetchStokGudangUseCase(repo);
  }

  late final FetchStokGudangUseCase _fetchStokGudang;

  bool _isLoading = false;
  String? _error;
  List<StokGudangItem> _all = const [];
  String? _kategoriFilter;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get kategoriFilter => _kategoriFilter;

  Set<String> get availableKategori => _all.map((i) => i.kategori).toSet();

  List<StokGudangItem> get filtered {
    return _all.where((i) {
      if (_kategoriFilter != null && i.kategori != _kategoriFilter) return false;
      if (_searchQuery.isNotEmpty &&
          !i.nama.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _fetchStokGudang();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat stok gudang. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setKategoriFilter(String? kategori) {
    if (_kategoriFilter == kategori) return;
    _kategoriFilter = kategori;
    notifyListeners();
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }
}
