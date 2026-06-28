import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/inventori_repository_impl.dart';
import '../../domain/entities/inventori_item.dart';
import '../../domain/repositories/inventori_repository.dart';
import '../../domain/usecases/fetch_inventori_usecase.dart';

enum InventoriStatusFilter { peringatanStok, tidakAdaStok }

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
  InventoriStatusFilter? _statusFilter;
  String _searchQuery = '';

  // ── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get kategoriFilter => _kategoriFilter;
  InventoriStatusFilter? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  Set<String> get availableKategori => _all.map((i) => i.kategori).toSet();

  /// Returns the image path (local file or network URL) of the first item
  /// in [kategori] that has an image, or null if none found.
  String? kategoriImage(String kategori) {
    for (final item in _all) {
      if (item.kategori == kategori) {
        final img = item.localImagePath ?? item.imageUrl;
        if (img != null) return img;
      }
    }
    return null;
  }

  List<InventoriItem> get filtered {
    return _all.where((i) {
      if (_statusFilter == InventoriStatusFilter.peringatanStok) {
        if (i.status != InventoriStatus.rendah) return false;
      } else if (_statusFilter == InventoriStatusFilter.tidakAdaStok) {
        if (i.status != InventoriStatus.habis) return false;
      } else if (_kategoriFilter != null && i.kategori != _kategoriFilter) {
        return false;
      }
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
    if (_kategoriFilter == kategori && _statusFilter == null) return;
    _kategoriFilter = kategori;
    _statusFilter = null;
    notifyListeners();
  }

  void setStatusFilter(InventoriStatusFilter? filter) {
    if (_statusFilter == filter && _kategoriFilter == null) return;
    _statusFilter = filter;
    _kategoriFilter = null;
    notifyListeners();
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void addItem(InventoriItem item) {
    _all = [item, ..._all];
    notifyListeners();
  }
}
