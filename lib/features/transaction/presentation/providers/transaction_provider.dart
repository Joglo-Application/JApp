import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../core/utils/id_generator.dart';

/// State for the transaction / history feature.
///
/// Also responsible for the checkout action (Cart → Transaction).
class TransactionProvider extends ChangeNotifier {
  TransactionProvider({required TransactionRepository repository})
      : _repository = repository;

  final TransactionRepository _repository;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isCheckingOut = false;
  String? _errorMessage;

  // ─── Public state ────────────────────────────────────────────────────────────
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  bool get isCheckingOut => _isCheckingOut;
  String? get errorMessage => _errorMessage;

  // ─── Dashboard stats ─────────────────────────────────────────────────────────

  double get totalRevenue =>
      _transactions.fold(0, (sum, t) => sum + t.totalAmount);

  int get totalTransactionCount => _transactions.length;

  double get todayRevenue {
    final now = DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.createdAt.year == now.year &&
              t.createdAt.month == now.month &&
              t.createdAt.day == now.day,
        )
        .fold(0, (sum, t) => sum + t.totalAmount);
  }

  int get todayTransactionCount {
    final now = DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.createdAt.year == now.year &&
              t.createdAt.month == now.month &&
              t.createdAt.day == now.day,
        )
        .length;
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  /// Loads all transactions from the repository.
  Future<void> loadTransactions() async {
    _setLoading(true);
    try {
      _transactions = await _repository.getTransactions();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Converts the current [cart] into a persisted [Transaction].
  ///
  /// Clears the cart on success. Returns `true` if checkout succeeded.
  Future<bool> checkout({
    required CartProvider cart,
    double taxRate = 0.0,
    String paymentMethod = 'Cash',
    String? note,
  }) async {
    if (cart.isEmpty) return false;

    _isCheckingOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final subtotal = cart.subtotal;
      final tax = cart.taxAmount(taxRate);

      final transaction = Transaction(
        id: IdGenerator.generate(),
        createdAt: DateTime.now(),
        totalAmount: subtotal + tax,
        taxAmount: tax,
        paymentMethod: paymentMethod,
        note: note,
        items: cart.items
            .map(
              (ci) => TransactionItem(
                productId: ci.product.id,
                productName: ci.product.name,
                unitPrice: ci.product.price,
                quantity: ci.quantity,
                note: ci.note,
              ),
            )
            .toList(),
      );

      await _repository.saveTransaction(transaction);
      _transactions = [transaction, ..._transactions];
      cart.clear();
      _isCheckingOut = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Checkout failed: $e';
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes a transaction by [id].
  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      _transactions = _transactions.where((t) => t.id != id).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      notifyListeners();
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
