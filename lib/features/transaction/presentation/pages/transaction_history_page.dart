import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_page.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_overlay.dart';

/// Lists all past transactions with search/filter capability.
class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const InlineLoader();

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.transactions.isEmpty) {
            return const EmptyStateWidget(
              message: 'No transactions yet.\nComplete a checkout to see history.',
              icon: Icons.receipt_long_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final tx = provider.transactions[index];
              return TransactionTile(
                transaction: tx,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TransactionDetailPage(transaction: tx),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
