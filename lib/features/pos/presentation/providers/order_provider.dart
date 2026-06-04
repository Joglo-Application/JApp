import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../../domain/entities/order_item.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({this.taxRate = 0.10});

  final double taxRate;
  final List<OrderItem> _items = [];
  String _customerName = '';

  String get customerName => _customerName;

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  UnmodifiableListView<OrderItem> get items => UnmodifiableListView(_items);

  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  int get totalQty => _items.fold(0, (s, i) => s + i.quantity);

  double get subtotal => _items.fold(0.0, (s, i) => s + i.subtotal);
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount;

  void addOrIncrement(OrderItem item) {
    final idx = _items.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void increment(String productId) {
    final idx = _items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    notifyListeners();
  }

  void decrement(String productId) {
    final idx = _items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    if (_items[idx].quantity <= 1) {
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity - 1);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((e) => e.productId == productId);
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
