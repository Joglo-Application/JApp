import '../entities/transaction.dart';

/// Contract for the transaction repository.
///
/// Future migration: only [TransactionRepositoryImpl] changes; this and
/// all callers (Provider, UI) remain completely untouched.
abstract class TransactionRepository {
  /// Returns all stored transactions, most recent first.
  Future<List<Transaction>> getTransactions();

  /// Returns transactions within [from]..[to] date range.
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime from,
    DateTime to,
  );

  /// Persists a new completed transaction.
  Future<void> saveTransaction(Transaction transaction);

  /// Permanently deletes a transaction by [id].
  Future<void> deleteTransaction(String id);
}
