import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';

/// Fixed-height green header used across the laporan tabs — both the left date
/// panel and the right panels — so the top bar lines up and stays the same size
/// on every tab. [child] (usually a Row or Text) is vertically centred.
class LaporanHeaderBar extends StatelessWidget {
  const LaporanHeaderBar({super.key, required this.child});

  final Widget child;

  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ColoredBox(
        color: AppColors.tertiary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ),
    );
  }
}
