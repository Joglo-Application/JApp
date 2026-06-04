import 'package:flutter/foundation.dart' hide Category;

import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

class MenuProvider extends ChangeNotifier {
  String? _selectedCategoryId;
  String _searchQuery = '';

  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<Category> get categories => _kCategories;

  List<Product> get filteredProducts {
    return _kProducts.where((p) {
      final matchesCategory = _selectedCategoryId == null ||
          p.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
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
}

// ── Mock data ─────────────────────────────────────────────────────────────────

const _kCategories = <Category>[
  Category(id: 'makanan', name: 'Makanan'),
  Category(id: 'ayam', name: 'Ayam & Bebek'),
  Category(id: 'seafood', name: 'Seafood'),
  Category(id: 'minuman', name: 'Minuman'),
  Category(id: 'dessert', name: 'Dessert'),
];

const _kProducts = <Product>[
  // Makanan
  Product(id: 'p01', name: 'Nasi Goreng', price: 25000, categoryId: 'makanan'),
  Product(id: 'p02', name: 'Mie Goreng', price: 22000, categoryId: 'makanan'),
  Product(id: 'p03', name: 'Nasi Putih', price: 5000, categoryId: 'makanan'),
  Product(id: 'p04', name: 'Nasi Uduk', price: 18000, categoryId: 'makanan'),
  Product(id: 'p05', name: 'Kwetiau Goreng', price: 28000, categoryId: 'makanan'),
  Product(id: 'p06', name: 'Bihun Goreng', price: 20000, categoryId: 'makanan', isAvailable: false),

  // Ayam & Bebek
  Product(id: 'p07', name: 'Ayam Goreng', price: 30000, categoryId: 'ayam'),
  Product(id: 'p08', name: 'Ayam Bakar', price: 35000, categoryId: 'ayam'),
  Product(id: 'p09', name: 'Bebek Goreng', price: 45000, categoryId: 'ayam'),
  Product(id: 'p10', name: 'Sate Ayam', price: 32000, categoryId: 'ayam'),
  Product(id: 'p11', name: 'Ayam Penyet', price: 33000, categoryId: 'ayam'),

  // Seafood
  Product(id: 'p12', name: 'Ikan Bakar', price: 55000, categoryId: 'seafood'),
  Product(id: 'p13', name: 'Cumi Goreng', price: 60000, categoryId: 'seafood'),
  Product(id: 'p14', name: 'Udang Goreng', price: 65000, categoryId: 'seafood'),
  Product(id: 'p15', name: 'Kepiting Saus', price: 90000, categoryId: 'seafood'),

  // Minuman
  Product(id: 'p16', name: 'Es Teh Manis', price: 5000, categoryId: 'minuman'),
  Product(id: 'p17', name: 'Jus Jeruk', price: 15000, categoryId: 'minuman'),
  Product(id: 'p18', name: 'Es Kopi Susu', price: 18000, categoryId: 'minuman'),
  Product(id: 'p19', name: 'Air Mineral', price: 5000, categoryId: 'minuman'),
  Product(id: 'p20', name: 'Jus Alpukat', price: 22000, categoryId: 'minuman'),
  Product(id: 'p21', name: 'Es Campur', price: 20000, categoryId: 'minuman'),

  // Dessert
  Product(id: 'p22', name: 'Pudding Coklat', price: 12000, categoryId: 'dessert'),
  Product(id: 'p23', name: 'Es Krim', price: 20000, categoryId: 'dessert'),
  Product(id: 'p24', name: 'Pisang Goreng', price: 15000, categoryId: 'dessert'),
  Product(id: 'p25', name: 'Kue Cubir', price: 10000, categoryId: 'dessert'),
];
