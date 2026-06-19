import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/kitchen_order.dart';

class KitchenOrderCard extends StatefulWidget {
  const KitchenOrderCard({
    super.key,
    required this.order,
    required this.onItemToggle,
    required this.onAllDone,
  });

  final KitchenOrder order;
  final void Function(int itemIndex) onItemToggle;
  final VoidCallback onAllDone;

  @override
  State<KitchenOrderCard> createState() => _KitchenOrderCardState();
}

class _KitchenOrderCardState extends State<KitchenOrderCard> {
  late Duration _elapsed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.order.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.order.startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final allDone =
        order.items.isNotEmpty && order.items.every((i) => i.isDone);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: allDone ? AppColors.tertiary : AppColors.primary,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(order: order, allDone: allDone),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
              itemCount: order.items.length,
              itemBuilder: (_, i) => _ItemRow(
                item: order.items[i],
                onToggle: () => widget.onItemToggle(i),
              ),
            ),
          ),
          _CardFooter(
            timerLabel: _timerLabel,
            allDone: allDone,
            onAllDone: widget.onAllDone,
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.order, required this.allDone});

  final KitchenOrder order;
  final bool allDone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: allDone ? AppColors.tertiary : AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x3,
        ),
        child: Text(
          '${order.tipe.label} - [${order.kodeTransaksi}]',
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.onToggle});

  final KitchenOrderItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${item.qty}',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: AppTypography.textTheme.bodyMedium,
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
          const SizedBox(width: AppSpacing.x2),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: item.isDone ? AppColors.tertiary : Colors.transparent,
                border: Border.all(
                  color: item.isDone ? AppColors.tertiary : AppColors.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: item.isDone
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.onTertiary)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    required this.timerLabel,
    required this.allDone,
    required this.onAllDone,
  });

  final String timerLabel;
  final bool allDone;
  final VoidCallback onAllDone;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: allDone ? AppColors.tertiary : AppColors.primary,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            Text(
              timerLabel,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: allDone ? AppColors.tertiary : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(),
            allDone ? _AllDoneBadge(onTap: onAllDone) : const _InProgressBadge(),
          ],
        ),
      ),
    );
  }
}

class _InProgressBadge extends StatelessWidget {
  const _InProgressBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded,
              size: 14, color: AppColors.onPrimary),
          const SizedBox(width: AppSpacing.x1),
          Text(
            'IN PROGRESS',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDoneBadge extends StatelessWidget {
  const _AllDoneBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x1,
        ),
        decoration: BoxDecoration(
          color: AppColors.tertiary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_box_rounded,
                size: 14, color: AppColors.onTertiary),
            const SizedBox(width: AppSpacing.x1),
            Text(
              'ALL DONE',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.onTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
