import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Shows the full breakdown of a single [Transaction].
class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateStr =
        DateFormat('EEEE, dd MMMM yyyy — HH:mm').format(transaction.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(transaction.totalAmount),
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Items ──────────────────────────────────────────────────────
          Text('Items', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...transaction.items.map((item) => _ItemRow(item: item)),
          const Divider(height: 24),

          // ── Breakdown ─────────────────────────────────────────────────
          _InfoRow(
            label: 'Subtotal',
            value: CurrencyFormatter.format(
              transaction.totalAmount - transaction.taxAmount,
            ),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Tax',
            value: CurrencyFormatter.format(transaction.taxAmount),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Total',
            value: CurrencyFormatter.format(transaction.totalAmount),
            isBold: true,
          ),
          const Divider(height: 24),

          // ── Payment ───────────────────────────────────────────────────
          _InfoRow(label: 'Payment', value: transaction.paymentMethod),
          if (transaction.note != null) ...[
            const SizedBox(height: 6),
            _InfoRow(label: 'Note', value: transaction.note!),
          ],
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Transaction ID',
            value: transaction.id.substring(0, 8).toUpperCase(),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '${CurrencyFormatter.format(item.unitPrice)} × ${item.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)
        : TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
