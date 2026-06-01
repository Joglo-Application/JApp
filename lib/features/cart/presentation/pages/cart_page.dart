import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/utils/currency_formatter.dart';

/// The cart page — shows all items, totals, and the checkout button.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.isEmpty
                ? const SizedBox.shrink()
                : TextButton.icon(
                    onPressed: () => _confirmClear(context, cart),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                    label: const Text('Clear'),
                  ),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return const EmptyStateWidget(
              message: 'Your cart is empty.\nAdd products to get started.',
              icon: Icons.shopping_cart_outlined,
            );
          }

          return Column(
            children: [
              // ── Item list ──────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  itemCount: cart.items.length,
                  itemBuilder: (_, index) =>
                      CartItemTile(item: cart.items[index]),
                ),
              ),

              // ── Order summary ──────────────────────────────────────────
              _OrderSummary(cart: cart),
            ],
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              cart.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart});

  final CartProvider cart;

  // Tax rate — in production this comes from SettingsProvider
  static const double _taxRate = 0.10;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: CurrencyFormatter.format(cart.subtotal),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Tax (${(_taxRate * 100).toStringAsFixed(0)}%)',
            value: CurrencyFormatter.format(cart.taxAmount(_taxRate)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _SummaryRow(
            label: 'Total',
            value: CurrencyFormatter.format(cart.grandTotal(_taxRate)),
            isTotal: true,
          ),
          const SizedBox(height: 16),
          Consumer<TransactionProvider>(
            builder: (context, txProvider, _) => AppButton(
              label: 'Checkout',
              icon: Icons.point_of_sale_outlined,
              isLoading: txProvider.isCheckingOut,
              onPressed: () => _checkout(context, txProvider),
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout(
      BuildContext context, TransactionProvider txProvider) async {
    final cart = context.read<CartProvider>();
    final success = await txProvider.checkout(
      cart: cart,
      taxRate: _taxRate,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Order placed successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(); // return to previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(txProvider.errorMessage ?? 'Checkout failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
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
