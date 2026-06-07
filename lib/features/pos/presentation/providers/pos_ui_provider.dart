import 'package:flutter/foundation.dart';

import '../../domain/entities/order_item.dart';

class PosUiProvider extends ChangeNotifier {
  OrderItem? _editingItem;

  OrderItem? get editingItem => _editingItem;

  void editItem(OrderItem item) {
    _editingItem = item;
    notifyListeners();
  }

  void clearEdit() {
    _editingItem = null;
    notifyListeners();
  }
}
