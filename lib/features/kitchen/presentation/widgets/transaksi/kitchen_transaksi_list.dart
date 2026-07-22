import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/kitchen_order.dart';

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String _formatDateTime(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final mon = _months[dt.month - 1];
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$d $mon ${dt.year} $h:$min';
}

String _itemSummary(List<KitchenOrderItem> items) =>
    items.map((i) => '${i.qty}x ${i.nama}').join(', ');

class KitchenTransaksiList extends StatelessWidget {
  const KitchenTransaksiList({
    super.key,
    required this.orders,
    required this.selectedId,
    required this.onSelect,
  });

  final List<KitchenOrder> orders;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada transaksi',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
      itemBuilder: (_, i) {
        final order = orders[i];
        final isSelected = order.id == selectedId;
        return _OrderListTile(
          order: order,
          isSelected: isSelected,
          onTap: () => onSelect(order.id),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final KitchenOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      KitchenOrderStatus.done => ('Selesai', Colors.green.shade700),
      KitchenOrderStatus.cancelled => ('Dibatalkan', AppColors.onSurfaceVariant),
      KitchenOrderStatus.inProgress => ('Diproses', Colors.orange.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  const _OrderListTile({
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  final KitchenOrder order;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryContainer : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      order.kodeTransaksi,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  _StatusChip(status: order.status),
                  const Spacer(),
                  Text(
                    _formatDateTime(order.startTime),
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x1),
              Text(
                _itemSummary(order.items),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
