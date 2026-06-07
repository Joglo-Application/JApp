import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../providers/order_provider.dart';
import '../product_panel/product_detail_form.dart';
import 'diskon_input.dart';

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
        onTap: () {},
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

// ── Action bar ────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar();

  @override
  Widget build(BuildContext context) {
    final actions = <_Action>[
      const _Action(icon: Icons.print_rounded, label: 'Cetak'),
      _Action(
        icon: Icons.percent_rounded,
        label: 'Diskon\nPesanan',
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => DiskonPesananDialog(
            title: 'Diskon Pesanan',
            onPromoSelected: (promo) => context
                .read<OrderProvider>()
                .setOrderDiscount(promo.discount, promo.discountType),
            onOpenInput: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (_) => const DiskonInputPage(),
            ),
          ),
        ),
      ),
      const _Action(icon: Icons.chat_bubble_rounded, label: 'Catatan\nPesanan'),
      const _Action(icon: Icons.send_rounded, label: 'Kirim\nDapur'),
      const _Action(icon: Icons.swap_horiz_rounded, label: 'In/Away'),
      const _Action(icon: Icons.chair_alt_rounded, label: 'Pilih\nMeja'),
      const _Action(icon: Icons.content_cut_rounded, label: 'Split Bill'),
      const _Action(icon: Icons.star_rounded, label: 'Loyalty\nPoint'),
      const _Action(icon: Icons.hourglass_empty_rounded, label: 'Pending'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions
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
  const _Action({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  static const double _size = 50;

  final _Action action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Material(
          color: AppColors.primary,
          borderRadius: AppRadius.md,
          child: InkWell(
            onTap: action.onTap,
            borderRadius: AppRadius.md,
            child: SizedBox(
              width: _size,
              height: _size,
              child: Icon(action.icon, size: 24, color: AppColors.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        SizedBox(
          width: _size,
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
    );
  }
}
