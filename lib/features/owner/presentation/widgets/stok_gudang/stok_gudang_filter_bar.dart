import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/stok_gudang_provider.dart';

class StokGudangFilterBar extends StatefulWidget {
  const StokGudangFilterBar({super.key});

  @override
  State<StokGudangFilterBar> createState() => _StokGudangFilterBarState();
}

class _StokGudangFilterBarState extends State<StokGudangFilterBar> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppColors.onPrimary, size: 22),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (q) =>
                    context.read<StokGudangProvider>().search(q),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary,
                ),
                cursorColor: AppColors.onPrimary,
                decoration: InputDecoration(
                  hintText: 'Cari',
                  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.6),
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
