import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../../domain/entities/order_item.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({this.taxRate = 0.10});

  final double taxRate;
  final List<OrderItem> _items = [];
  String _customerName = '';
  double _orderDiscount = 0;
  DiscountType _orderDiscountType = DiscountType.amount;
  String? _orderPromoName;
  String _orderNote = '';
  OrderType? _orderType;

  String get customerName => _customerName;
  double get orderDiscount => _orderDiscount;
  DiscountType get orderDiscountType => _orderDiscountType;
  String? get orderPromoName => _orderPromoName;
  String get orderNote => _orderNote;
  OrderType? get orderType => _orderType;

  void setOrderNote(String note) {
    _orderNote = note;
    notifyListeners();
  }

  void setOrderType(OrderType type) {
    _orderType = type;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setOrderDiscount(double discount, DiscountType type, {String? promoName}) {
    _orderDiscount = discount;
    _orderDiscountType = type;
    _orderPromoName = promoName;
    notifyListeners();
  }

  UnmodifiableListView<OrderItem> get items => UnmodifiableListView(_items);

  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  int get totalQty => _items.fold(0, (s, i) => s + i.quantity);

  double get subtotal => _items.fold(0.0, (s, i) => s + i.subtotal);
  double get taxAmount => subtotal * taxRate;

  double get orderDiscountAmount {
    if (_orderDiscount <= 0) return 0;
    if (_orderDiscountType == DiscountType.percent) {
      return subtotal * (_orderDiscount / 100);
    }
    return _orderDiscount;
  }

  double get total => subtotal + taxAmount - orderDiscountAmount;

  void addOrIncrement(OrderItem item) {
    final idx = _items.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void addFromForm(OrderItem item) {
    final idx = _items.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        quantity: _items[idx].quantity + item.quantity,
        discount: item.discount,
        discountType: item.discountType,
        note: item.note,
      );
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

  void replaceItem(OrderItem item) {
    final idx = _items.indexWhere((e) => e.productId == item.productId);
    if (idx < 0) return;
    _items[idx] = item;
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((e) => e.productId == productId);
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty && _orderDiscount == 0 && _orderNote.isEmpty) return;
    _items.clear();
    _orderDiscount = 0;
    _orderDiscountType = DiscountType.amount;
    _orderPromoName = null;
    _orderNote = '';
    _orderType = null;
    notifyListeners();
  }
}

enum OrderType {
  dineIn,
  takeAway,
  goFood,
  grabFood,
  shopeeFood;

  String get label => switch (this) {
        OrderType.dineIn => 'DINE-IN',
        OrderType.takeAway => 'TAKE-AWAY',
        OrderType.goFood => 'GOFOOD',
        OrderType.grabFood => 'GRABFOOD',
        OrderType.shopeeFood => 'SHOPEEFOOD',
      };
}
