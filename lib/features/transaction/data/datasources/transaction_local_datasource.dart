import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../models/transaction_model.dart';

/// The ONLY class that directly accesses Hive for transactions.
class TransactionLocalDataSource {
  TransactionLocalDataSource(this._box);

  final Box<TransactionModel> _box;

  /// Returns all transactions sorted by date descending (newest first).
  Future<List<domain.Transaction>> getTransactions() async {
    final list = _box.values.map((m) => m.toEntity()).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Returns transactions in the [from]..[to] date range, newest first.
  Future<List<domain.Transaction>> getTransactionsByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final list = _box.values
        .where(
          (m) =>
              !m.createdAt.isBefore(from) &&
              !m.createdAt.isAfter(to.add(const Duration(days: 1))),
        )
        .map((m) => m.toEntity())
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Persists a new [transaction].
  Future<void> saveTransaction(domain.Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _box.put(transaction.id, model);
  }

  /// Deletes the transaction identified by [id].
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }
}
