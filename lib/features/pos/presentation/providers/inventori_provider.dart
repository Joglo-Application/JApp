import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/inventori_repository_impl.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/entities/create_menu_params.dart';
import '../../domain/entities/inventori_item.dart';
import '../../domain/repositories/inventori_repository.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../domain/usecases/create_menu_usecase.dart';
import '../../domain/usecases/fetch_inventori_usecase.dart';

enum InventoriStatusFilter { peringatanStok, tidakAdaStok }

class InventoriProvider extends ChangeNotifier {
  InventoriProvider({
    InventoriRepository? repository,
    MenuRepository? menuRepository,
  }) {
    _fetchInventori =
        FetchInventoriUseCase(repository ?? InventoriRepositoryImpl());
    _createMenu = CreateMenuUseCase(menuRepository ?? MenuRepositoryImpl());
  }

  late final FetchInventoriUseCase _fetchInventori;
  late final CreateMenuUseCase _createMenu;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String? _submitError;
  List<InventoriItem> _all = const [];
  String? _kategoriFilter;
  InventoriStatusFilter? _statusFilter;
  String _searchQuery = '';

  // ── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get submitError => _submitError;
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

  /// Creates a new menu product (`POST /menus`) then refreshes the list from
  /// `GET /inventori` so it appears. Returns `true` on success; see
  /// [submitError] on failure.
  Future<bool> tambahProduk(CreateMenuParams params) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();
    try {
      await _createMenu(params);
      await load();
      return true;
    } on ApiException catch (e) {
      _submitError = e.message;
      return false;
    } catch (_) {
      _submitError = 'Gagal menambah produk.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
