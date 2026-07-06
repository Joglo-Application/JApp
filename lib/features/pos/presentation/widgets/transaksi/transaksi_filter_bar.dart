import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/transaksi_provider.dart';

class TransaksiFilterBar extends StatefulWidget {
  const TransaksiFilterBar({super.key});

  @override
  State<TransaksiFilterBar> createState() => _TransaksiFilterBarState();
}

class _TransaksiFilterBarState extends State<TransaksiFilterBar> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openSearch() => setState(() => _searching = true);

  void _closeSearch() {
    _searchCtrl.clear();
    context.read<TransaksiProvider>().setSearchQuery('');
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: _searching ? _buildSearchRow() : _buildFilterRow(),
      ),
    );
  }

  Widget _buildFilterRow() {
    final activeFilter = context.select<TransaksiProvider, String?>(
      (p) => p.paymentTypeFilter,
    );

    return Row(
      children: [
        InkWell(
          onTap: _openSearch,
          child: const Icon(
            Icons.search_rounded,
            color: AppColors.onPrimary,
            size: 22,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _showPaymentTypeFilter(context),
            child: Text(
              activeFilter ?? 'Semua Tipe Pembayaran',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Icon(Icons.sort_rounded, color: AppColors.onPrimary, size: 22),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        const Icon(Icons.search_rounded, color: AppColors.onPrimary, size: 22),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onPrimary,
            ),
            cursorColor: AppColors.onPrimary,
            decoration: InputDecoration(
              hintText: 'Cari Kode Transaksi…',
              hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.6),
              ),
              isDense: true,
              border: InputBorder.none,
            ),
            onChanged: (q) =>
                context.read<TransaksiProvider>().setSearchQuery(q),
          ),
        ),
        InkWell(
          onTap: _closeSearch,
          child: const Icon(
            Icons.close_rounded,
            color: AppColors.onPrimary,
            size: 22,
          ),
        ),
      ],
    );
  }

  void _showPaymentTypeFilter(BuildContext context) {
    final provider = context.read<TransaksiProvider>();
    final types = provider.availablePaymentTypes.toList()..sort();
    final current = provider.paymentTypeFilter;

    showDialog<String?>(
      context: context,
      builder: (_) => _PaymentTypeDialog(
        types: types,
        selected: current,
      ),
    ).then((picked) {
      if (picked == null) return; // dismissed
      provider.setPaymentTypeFilter(
        picked == '' ? null : picked,
      );
    });
  }
}

class _PaymentTypeDialog extends StatelessWidget {
  const _PaymentTypeDialog({required this.types, required this.selected});

  final List<String> types;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('', 'Semua Tipe Pembayaran'),
      ...types.map((t) => (t, t)),
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.25,
        vertical: AppSpacing.x8,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list_rounded,
                        color: AppColors.onPrimary, size: 20),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'Tipe Pembayaran',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.onPrimary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            ColoredBox(
              color: AppColors.primaryContainer,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    _OptionTile(
                      label: options[i].$2,
                      isSelected: (options[i].$1 == '') == (selected == null)
                          ? (options[i].$1 == '')
                          : options[i].$1 == selected,
                      onTap: () => Navigator.of(context).pop(options[i].$1),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.onPrimaryContainer,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded,
                  color: AppColors.onPrimaryContainer, size: 18),
          ],
        ),
      ),
    );
  }
}
