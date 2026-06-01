import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../transaction/presentation/pages/transaction_history_page.dart';
import '../../../product/presentation/pages/product_list_page.dart';
import '../../../../core/utils/currency_formatter.dart';

/// The home/dashboard page — summary stats and quick actions.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final greeting = _greeting();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<TransactionProvider>().loadTransactions();
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Header ──────────────────────────────────────────────────
              Text(
                greeting,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                dateStr,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // ── Today's stats ────────────────────────────────────────────
              Text(
                "Today's Overview",
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Consumer<TransactionProvider>(
                builder: (context, provider, _) => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Revenue',
                        value: CurrencyFormatter.format(provider.todayRevenue),
                        icon: Icons.payments_outlined,
                        color: colorScheme.primaryContainer,
                        iconColor: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Orders',
                        value: '${provider.todayTransactionCount}',
                        icon: Icons.receipt_outlined,
                        color: colorScheme.secondaryContainer,
                        iconColor: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Consumer2<ProductProvider, CategoryProvider>(
                builder: (context, prodProvider, catProvider, _) => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Products',
                        value: '${prodProvider.products.length}',
                        icon: Icons.inventory_2_outlined,
                        color: colorScheme.tertiaryContainer,
                        iconColor: colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Categories',
                        value: '${catProvider.categories.length}',
                        icon: Icons.category_outlined,
                        color: colorScheme.surfaceContainerHighest,
                        iconColor: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── All-time stats ───────────────────────────────────────────
              Text(
                'All Time',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Consumer<TransactionProvider>(
                builder: (context, provider, _) => _StatCard(
                  label: 'Total Revenue',
                  value: CurrencyFormatter.format(provider.totalRevenue),
                  icon: Icons.bar_chart_outlined,
                  color: colorScheme.primaryContainer,
                  iconColor: colorScheme.primary,
                  isWide: true,
                ),
              ),
              const SizedBox(height: 28),

              // ── Quick actions ────────────────────────────────────────────
              Text(
                'Quick Actions',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _QuickAction(
                icon: Icons.inventory_2_outlined,
                label: 'Manage Products',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductListPage()),
                ),
              ),
              const SizedBox(height: 8),
              _QuickAction(
                icon: Icons.history_outlined,
                label: 'Transaction History',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const TransactionHistoryPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 🌙';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.isWide = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isWide
          ? Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500)),
                    Text(value,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(height: 10),
                Text(label,
                    style: textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right,
            color: colorScheme.onSurfaceVariant),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
