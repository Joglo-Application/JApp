import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class PosAppBar extends StatelessWidget {
  const PosAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:  BoxDecoration(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _MenuButton(),
                  const SizedBox(width: AppSpacing.x3),
                  Text(
                    'Point of Sale',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x3),
              const _ActionBar(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu button ───────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 60,
          height: 60,
          child: Icon(Icons.menu_rounded, color: AppColors.onPrimary, size: 28),
        ),
      ),
    );
  }
}

// ── Action bar ────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar();

  static const _actions = <_Action>[
    _Action(icon: Icons.print_rounded, label: 'Cetak'),
    _Action(icon: Icons.percent_rounded, label: 'Diskon Pesanan'),
    _Action(icon: Icons.chat_bubble_rounded, label: 'Catatan Pesanan'),
    _Action(icon: Icons.send_rounded, label: 'Kirim Dapur'),
    _Action(icon: Icons.swap_horiz_rounded, label: 'In/Away'),
    _Action(icon: Icons.chair_alt_rounded, label: 'Pilih Meja'),
    _Action(icon: Icons.content_cut_rounded, label: 'Split Bill'),
    _Action(icon: Icons.star_rounded, label: 'Loyalty Point'),
    _Action(icon: Icons.hourglass_empty_rounded, label: 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _actions
            .map(
              (a) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.x2),
                child: _ActionButton(action: a),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Action {
  const _Action({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  static const double _box = 56; // square icon button (width == height)
  // Two lines of labelSmall (11px × 1.45 ≈ 16px/line) plus a small margin, so
  // every button is the same height whether its label wraps to one or two
  // lines — which keeps the squares tightly and evenly spaced.
  static const double _labelHeight = 34;

  final _Action action;

  @override
  Widget build(BuildContext context) {
    // Cell width == the square, so squares sit close together (the gap is the
    // _ActionBar's 8px padding). Labels wrap to two lines within that width.
    return SizedBox(
      width: _box,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: AppColors.primary,
            borderRadius: AppRadius.md,
            child: InkWell(
              onTap: () {},
              borderRadius: AppRadius.md,
              child: SizedBox(
                width: _box,
                height: _box,
                child: Center(
                  child: Icon(
                    action.icon,
                    size: 24,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          SizedBox(
            height: _labelHeight,
            child: Text(
              action.label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.onSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
