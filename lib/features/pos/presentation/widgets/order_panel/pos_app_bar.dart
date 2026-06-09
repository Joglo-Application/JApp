import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../pages/pilih_meja_page.dart';
import '../../providers/order_provider.dart';
import '../product_panel/product_detail_form.dart';
import 'diskon_input.dart';

class PosAppBar extends StatelessWidget {
  const PosAppBar({super.key});

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
                .setOrderDiscount(promo.discount, promo.discountType, promoName: promo.name),
            onOpenInput: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (_) => const DiskonInputPage(),
            ),
          ),
        ),
      ),
      _Action(
        icon: Icons.chat_bubble_rounded,
        label: 'Catatan\nPesanan',
        onTap: () {
          final provider = context.read<OrderProvider>();
          showDialog<String>(
            context: context,
            builder: (_) => CatatanPesananDialog(
              initialNote: provider.orderNote,
            ),
          ).then((note) {
            if (note != null) provider.setOrderNote(note);
          });
        },
      ),
      _Action(
        icon: Icons.send_rounded,
        label: 'Kirim\nDapur',
        onTap: () {
          final messenger = ScaffoldMessenger.of(context);
          showDialog<bool>(
            context: context,
            builder: (_) => const _KirimDapurDialog(),
          ).then((confirmed) {
            if (confirmed == true) {
              messenger.showSnackBar(
                SnackBar(
                  content: const Text(
                    'Berhasil kirim ke Dapur',
                    style: TextStyle(color: AppColors.onTertiary),
                  ),
                  backgroundColor: AppColors.tertiary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        },
      ),
      _Action(
        icon: Icons.swap_horiz_rounded,
        label: 'In/Away',
        onTap: () {
          final provider = context.read<OrderProvider>();
          showDialog<OrderType>(
            context: context,
            builder: (_) => const _InAwayDialog(),
          ).then((type) {
            if (type != null) provider.setOrderType(type);
          });
        },
      ),
      _Action(
        icon: Icons.chair_alt_rounded,
        label: 'Pilih\nMeja',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PilihMejaPage()),
        ),
      ),
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

  static const double _box = 48; // square icon button (width == height)
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
              onTap: action.onTap,
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

// ── In/Away dialog ────────────────────────────────────────────────────────────

class _InAwayDialog extends StatelessWidget {
  const _InAwayDialog();

  static const _types = OrderType.values;

  @override
  Widget build(BuildContext context) {
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
              // Header
              ColoredBox(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                    vertical: AppSpacing.x3,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_rounded, color: AppColors.onPrimary, size: 22),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                        child: Text(
                          'Dine In/Take Away',
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
              // Options
              ColoredBox(
                color: AppColors.primaryContainer,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _types.map((type) {
                    final isLast = type == _types.last;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(type),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.x4,
                              vertical: AppSpacing.x4,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                type.label,
                                style: AppTypography.textTheme.titleSmall?.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

// ── Kirim Dapur dialog ────────────────────────────────────────────────────────

class _KirimDapurDialog extends StatelessWidget {
  const _KirimDapurDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x6,
                AppSpacing.x6,
                AppSpacing.x4,
                AppSpacing.x4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: AppColors.onPrimary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        Text(
                          'Kirim Dapur?',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        Text(
                          'Apakah anda ingin mengirim pesanan ini ke dapur?',
                          style: AppTypography.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Tidak',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Ya',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
