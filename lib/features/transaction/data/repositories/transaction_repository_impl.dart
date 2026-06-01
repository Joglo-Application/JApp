import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

/// Concrete implementation of [TransactionRepository] backed by Hive.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({required this.localDataSource});

  final TransactionLocalDataSource localDataSource;

  @override
  Future<List<Transaction>> getTransactions() =>
      localDataSource.getTransactions();

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime from,
    DateTime to,
  ) =>
      localDataSource.getTransactionsByDateRange(from, to);

  @override
  Future<void> saveTransaction(Transaction transaction) =>
      localDataSource.saveTransaction(transaction);

  @override
  Future<void> deleteTransaction(String id) =>
      localDataSource.deleteTransaction(id);
}
