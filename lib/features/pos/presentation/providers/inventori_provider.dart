import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/inventori_repository_impl.dart';
import '../../domain/entities/inventori_item.dart';
import '../../domain/repositories/inventori_repository.dart';
import '../../domain/usecases/fetch_inventori_usecase.dart';

class InventoriProvider extends ChangeNotifier {
  InventoriProvider({InventoriRepository? repository}) {
    final repo = repository ?? InventoriRepositoryImpl();
    _fetchInventori = FetchInventoriUseCase(repo);
  }

  late final FetchInventoriUseCase _fetchInventori;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;
  List<InventoriItem> _all = const [];
  String? _kategoriFilter;
  String _searchQuery = '';

  // ── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get kategoriFilter => _kategoriFilter;
  String get searchQuery => _searchQuery;

  Set<String> get availableKategori => _all.map((i) => i.kategori).toSet();

  List<InventoriItem> get filtered {
    return _all.where((i) {
      if (_kategoriFilter != null && i.kategori != _kategoriFilter) return false;
      if (_searchQuery.isNotEmpty &&
          !i.nama.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _fetchInventori();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat inventori. Coba lagi.';
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
