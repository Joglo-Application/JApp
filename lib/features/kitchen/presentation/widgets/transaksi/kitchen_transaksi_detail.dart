import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/kitchen_order.dart';

class KitchenTransaksiDetail extends StatelessWidget {
  const KitchenTransaksiDetail({
    super.key,
    required this.order,
    required this.onItemToggle,
    required this.onClose,
    required this.onPrint,
  });

  final KitchenOrder order;
  final void Function(int index) onItemToggle;
  final VoidCallback onClose;
  final VoidCallback onPrint;

  bool get _allDone =>
      order.items.isNotEmpty && order.items.every((i) => i.isDone);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailHeader(
          order: order,
          allDone: _allDone,
          onClose: onClose,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: order.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
            itemBuilder: (_, i) => _ItemDetailRow(
              item: order.items[i],
              onToggle: () => onItemToggle(i),
            ),
          ),
        ),
        _PrintButton(onPrint: onPrint),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.order,
    required this.allDone,
    required this.onClose,
  });

  final KitchenOrder order;
  final bool allDone;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            _StatusBadge(allDone: allDone),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                '[${order.kodeTransaksi}]',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(6),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.close_rounded,
                      color: AppColors.onPrimary, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.allDone});

  final bool allDone;

  @override
  Widget build(BuildContext context) {
    final color = allDone ? AppColors.tertiary : AppColors.primary;
    final icon =
        allDone ? Icons.check_circle_rounded : Icons.access_time_rounded;
    final label = allDone ? 'ALL DONE' : 'IN PROGRESS';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: AppSpacing.x1),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item row ──────────────────────────────────────────────────────────────────

class _ItemDetailRow extends StatelessWidget {
  const _ItemDetailRow({required this.item, required this.onToggle});

  final KitchenOrderItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image placeholder
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          // Name + qty + catatan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${item.qty}',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (item.catatan.isNotEmpty)
                  Text(
                    item.catatan,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          // Status button
          _ItemStatusButton(isDone: item.isDone, onToggle: onToggle),
        ],
      ),
    );
  }
}

class _ItemStatusButton extends StatelessWidget {
  const _ItemStatusButton({required this.isDone, required this.onToggle});

  final bool isDone;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = isDone ? AppColors.tertiary : AppColors.onSurfaceVariant;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDone)
              Icon(Icons.check_rounded, size: 16, color: color),
            Text(
              isDone ? 'Done' : 'In\nProgress',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Print footer ──────────────────────────────────────────────────────────────

class _PrintButton extends StatelessWidget {
  const _PrintButton({required this.onPrint});

  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: InkWell(
        onTap: onPrint,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.print_rounded,
                  color: AppColors.onPrimary, size: 20),
              const SizedBox(width: AppSpacing.x2),
              Text(
                'Print Transaksi',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
