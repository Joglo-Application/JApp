import 'package:flutter/foundation.dart' hide Category;

import '../../../../core/network/api_exception.dart';
import '../../data/menu_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

class MenuProvider extends ChangeNotifier {
  MenuProvider({MenuRepository? repository})
      : _repo = repository ?? MenuRepository();

  final MenuRepository _repo;

  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  bool _isSubmitting = false;
  String? _submitError;
  List<Product> _products = const [];
  String? _selectedCategoryId;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  /// Distinct categories derived from the fetched menus (the API stores
  /// `kategori` as a free-text string on each menu).
  List<Category> get categories {
    final seen = <String>{};
    final result = <Category>[];
    for (final p in _products) {
      if (p.categoryId.isNotEmpty && seen.add(p.categoryId)) {
        result.add(Category(id: p.categoryId, name: _label(p.categoryId)));
      }
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCategory =
          _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Fetches the menu list from the backend. Call once when the POS screen
  /// opens; use [refresh] to force a reload.
  Future<void> loadMenus() async {
    if (_hasLoaded || _isLoading) return;
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repo.fetchMenus();
      _hasLoaded = true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat menu. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// POST /menus then reloads the list so the new menu shows in the grid.
  /// Returns `true` on success; read [submitError] on failure.
  Future<bool> createMenu({
    required String namaMenu,
    required String kategori,
    required int harga,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _repo.createMenu(
        namaMenu: namaMenu,
        kategori: kategori,
        harga: harga,
      );
      _products = await _repo.fetchMenus();
      _hasLoaded = true;
      return true;
    } on ApiException catch (e) {
      _submitError = e.message;
      return false;
    } catch (_) {
      _submitError = 'Gagal menambah menu. Coba lagi.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// "minuman" → "Minuman", "nasi goreng" → "Nasi Goreng".
  String _label(String raw) => raw
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
