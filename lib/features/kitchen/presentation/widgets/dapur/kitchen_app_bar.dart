import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/kitchen_order.dart';

class KitchenAppBar extends StatelessWidget {
  const KitchenAppBar({
    super.key,
    this.onRefresh,
    this.selectedFilter,
    this.onFilterChanged,
  });

  final VoidCallback? onRefresh;
  final KitchenOrderType? selectedFilter;
  final ValueChanged<KitchenOrderType?>? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(
          bottom: BorderSide(color: AppColors.secondaryContainer),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              _MenuButton(),
              const SizedBox(width: AppSpacing.x3),
              Text(
                'Dapur',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _AllGroupsButton(
                selected: selectedFilter,
                onChanged: onFilterChanged,
              ),
              const SizedBox(width: AppSpacing.x2),
              _RefreshButton(onRefresh: onRefresh),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(Icons.menu_rounded, color: AppColors.onPrimary, size: 28),
        ),
      ),
    );
  }
}

class _AllGroupsButton extends StatelessWidget {
  const _AllGroupsButton({this.selected, this.onChanged});

  final KitchenOrderType? selected;
  final ValueChanged<KitchenOrderType?>? onChanged;

  String get _label => selected == null ? 'All Groups' : selected!.label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showFilterDialog(context),
      icon: const Icon(
        Icons.filter_list_rounded,
        color: AppColors.primary,
        size: 18,
      ),
      label: Text(
        _label,
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.onSecondary,
        // side: const BorderSide(color: AppColors.onWarning),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final result = await showDialog<_FilterSelection>(
      context: context,
      builder: (_) => _FilterDialog(selected: selected),
    );
    if (result != null) onChanged?.call(result.type);
  }
}

/// Wraps dialog result so null = dismissed, non-null = user made a choice.
/// [type] == null means "All Groups" (clear filter).
class _FilterSelection {
  const _FilterSelection(this.type);
  final KitchenOrderType? type;
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onRefresh,
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.refresh_rounded,
            color: AppColors.onSecondary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// ── Filter dialog ─────────────────────────────────────────────────────────────

class _FilterDialog extends StatelessWidget {
  const _FilterDialog({this.selected});

  final KitchenOrderType? selected;

  static const _kBodyGold = Color(0xFFC49A22);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.3,
        vertical: AppSpacing.x8,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x4,
                  AppSpacing.x4,
                  AppSpacing.x2,
                  AppSpacing.x4,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.onPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'All Groups',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close,
                          color: AppColors.onPrimary, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            // Options
            ColoredBox(
              color: _kBodyGold,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FilterOption(
                    label: 'All Groups',
                    isSelected: selected == null,
                    onTap: () => Navigator.of(context)
                        .pop(const _FilterSelection(null)),
                  ),
                  _Divider(),
                  _FilterOption(
                    label: KitchenOrderType.dineIn.label,
                    isSelected: selected == KitchenOrderType.dineIn,
                    onTap: () => Navigator.of(context)
                        .pop(_FilterSelection(KitchenOrderType.dineIn)),
                  ),
                  _Divider(),
                  _FilterOption(
                    label: KitchenOrderType.takeAway.label,
                    isSelected: selected == KitchenOrderType.takeAway,
                    onTap: () => Navigator.of(context)
                        .pop(_FilterSelection(KitchenOrderType.takeAway)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Colors.white24,
    );
  }
}
