import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../../domain/entities/order_item.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({this.taxRate = 0.10});

  final double taxRate;
  final List<OrderItem> _items = [];
  String _customerName = '';
  int? _memberPoints;
  double _orderDiscount = 0;
  DiscountType _orderDiscountType = DiscountType.amount;
  String? _orderPromoName;
  String _orderNote = '';
  OrderType? _orderType;
  int? _redeemedPointCost;
  double _redeemDiscount = 0;
  DiscountType _redeemDiscountType = DiscountType.amount;
  String? _redeemRewardName;
  String? _redeemedItemId;
  double? _redeemDisplayValue;

  String get customerName => _customerName;
  int? get memberPoints => _memberPoints;
  double get orderDiscount => _orderDiscount;
  DiscountType get orderDiscountType => _orderDiscountType;
  String? get orderPromoName => _orderPromoName;
  String get orderNote => _orderNote;
  OrderType? get orderType => _orderType;
  int? get redeemedPointCost => _redeemedPointCost;
  String? get redeemRewardName => _redeemRewardName;
  String? get redeemedItemId => _redeemedItemId;

  double get redeemDiscountAmount {
    if (_redeemDiscount <= 0) return 0;
    if (_redeemDiscountType == DiscountType.percent) {
      return subtotal * (_redeemDiscount / 100);
    }
    return _redeemDiscount;
  }

  // For free-item rewards this holds the item's unit price (informational display).
  // For discount rewards it falls back to the computed discount amount.
  double get redeemDisplayValue => _redeemDisplayValue ?? redeemDiscountAmount;

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
    _memberPoints = null;
    notifyListeners();
  }

  void setMember(String name, int points) {
    _customerName = name;
    _memberPoints = points;
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

  // Free-item reward is excluded from subtotal so taxes are not inflated.
  double get subtotal => _items
      .where((i) => i.productId != _redeemedItemId)
      .fold(0.0, (s, i) => s + i.subtotal);
  double get taxAmount => subtotal * taxRate;

  double get orderDiscountAmount {
    if (_orderDiscount <= 0) return 0;
    if (_orderDiscountType == DiscountType.percent) {
      return subtotal * (_orderDiscount / 100);
    }
    return _orderDiscount;
  }

  double get total => subtotal + taxAmount - orderDiscountAmount - redeemDiscountAmount;

  int get earnedPoints => (subtotal / 2000).floor();

  void _clearRedemptionState() {
    if (_redeemedItemId != null) {
      _items.removeWhere((e) => e.productId == _redeemedItemId);
      _redeemedItemId = null;
    }
    _redeemedPointCost = null;
    _redeemDiscount = 0;
    _redeemDiscountType = DiscountType.amount;
    _redeemRewardName = null;
    _redeemDisplayValue = null;
  }

  void redeemReward(String name, int pointCost, double discount, DiscountType type) {
    if (_memberPoints == null) return;
    if (_redeemedPointCost != null) {
      _memberPoints = _memberPoints! + _redeemedPointCost!;
    }
    _clearRedemptionState();
    _redeemedPointCost = pointCost;
    _redeemDiscount = discount;
    _redeemDiscountType = type;
    _redeemRewardName = name;
    _memberPoints = _memberPoints! - pointCost;
    notifyListeners();
  }

  void redeemFreeItem({
    required String name,
    required int pointCost,
    required OrderItem item,
    required double displayValue,
  }) {
    if (_memberPoints == null) return;
    if (_redeemedPointCost != null) {
      _memberPoints = _memberPoints! + _redeemedPointCost!;
    }
    _clearRedemptionState();
    _redeemedPointCost = pointCost;
    _redeemRewardName = name;
    _redeemDisplayValue = displayValue;
    _redeemedItemId = item.productId;
    _memberPoints = _memberPoints! - pointCost;
    _items.add(item);
    notifyListeners();
  }

  void removeRedemption() {
    if (_redeemedPointCost == null) return;
    _memberPoints = (_memberPoints ?? 0) + _redeemedPointCost!;
    _clearRedemptionState();
    notifyListeners();
  }

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
    if (productId == _redeemedItemId) {
      _memberPoints = (_memberPoints ?? 0) + (_redeemedPointCost ?? 0);
      _clearRedemptionState();
    } else {
      _items.removeWhere((e) => e.productId == productId);
    }
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty && _orderDiscount == 0 && _orderNote.isEmpty &&
        _memberPoints == null && _redeemedPointCost == null) {
      return;
    }
    _items.clear();
    _orderDiscount = 0;
    _orderDiscountType = DiscountType.amount;
    _orderPromoName = null;
    _orderNote = '';
    _orderType = null;
    _memberPoints = null;
    _redeemedPointCost = null;
    _redeemDiscount = 0;
    _redeemDiscountType = DiscountType.amount;
    _redeemRewardName = null;
    _redeemedItemId = null;
    _redeemDisplayValue = null;
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
