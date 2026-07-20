import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../pages/payment_page.dart';
import '../../pages/pesanan_pending_page.dart';
import '../../pages/pilih_meja_page.dart';
import '../../../data/datasources/loyalty_remote_datasource.dart';
import '../../../domain/entities/order_item.dart';
import '../../providers/order_provider.dart';
import '../order_panel/diskon_input.dart';
import '../product_panel/product_detail_form.dart';

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
            subtotal: context.read<OrderProvider>().subtotal.round(),
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
        onTap: () async {
          final order = context.read<OrderProvider>();
          final messenger = ScaffoldMessenger.of(context);

          if (order.isEmpty) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Belum ada item pesanan')),
            );
            return;
          }
          if (order.isSentToKitchen) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Pesanan sudah dikirim ke dapur')),
            );
            return;
          }

          // Tanpa In/Away → default Take-Away, langsung lanjut (tak perlu pilih
          // ulang). Dine-In bersifat opt-in dan butuh meja.
          if (order.effectiveOrderType == OrderType.dineIn &&
              order.mejaId == null) {
            if (!context.mounted) return;
            final selected = await Navigator.of(context).push<SelectedMeja>(
              MaterialPageRoute<SelectedMeja>(
                builder: (_) => const PilihMejaPage(),
              ),
            );
            if (selected == null) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Pilih nomor meja dulu untuk pesanan Dine-In'),
                ),
              );
              return;
            }
            order.setMeja(selected.mejaId, selected.nomor);
          }

          if (!context.mounted) return;
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => const _KirimDapurDialog(),
          );
          if (confirmed != true) return;

          final ok = await order.kirimDapur();
          if (!ok) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  order.submitError ?? 'Gagal kirim ke Dapur',
                  style: const TextStyle(color: AppColors.onError),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          if (!context.mounted) return;
          if (order.effectiveOrderType == OrderType.dineIn) {
            // Dine-In: pesanan diparkir di meja, dibayar nanti lewat "Lihat
            // Pesanan" → panel dikosongkan.
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Pesanan dikirim ke dapur',
                  style: TextStyle(color: AppColors.onTertiary),
                ),
                backgroundColor: AppColors.tertiary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            order.clear();
          } else {
            // Take-Away/online: pesanan sudah dibuat & masuk dapur → langsung
            // ke pembayaran (memakai pesananId yang sama, tidak dibuat ulang).
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PaymentPage()),
            );
          }
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
        onTap: () async {
          final selected = await Navigator.of(context).push<SelectedMeja>(
            MaterialPageRoute<SelectedMeja>(
              builder: (_) => const PilihMejaPage(),
            ),
          );
          if (selected != null && context.mounted) {
            context
                .read<OrderProvider>()
                .setMeja(selected.mejaId, selected.nomor);
          }
        },
      ),
      _Action(
        icon: Icons.content_cut_rounded,
        label: 'Split Bill',
        onTap: () {
          final provider = context.read<OrderProvider>();
          final messenger = ScaffoldMessenger.of(context);
          if (provider.items.isEmpty) return;
          showDialog<List<String>>(
            context: context,
            builder: (_) => _SplitBillDialog(items: provider.items.toList()),
          ).then((selectedIds) async {
            if (selectedIds == null || selectedIds.isEmpty) return;
            final selected = provider.items
                .where((i) => selectedIds.contains(i.productId))
                .toList();
            // Simpan subset terpilih sebagai draft held di backend.
            final ok = await provider.holdItems(selected, provider.customerName);
            if (ok) {
              for (final id in selectedIds) {
                provider.remove(id);
              }
              await refreshPendingOrders();
              messenger.showSnackBar(
                const SnackBar(content: Text('Sebagian pesanan disimpan ke Pending')),
              );
            } else {
              messenger.showSnackBar(
                SnackBar(content: Text(provider.submitError ?? 'Gagal split bill')),
              );
            }
          });
        },
      ),
      _Action(
        icon: Icons.star_rounded,
        label: 'Loyalty\nPoint',
        onTap: () {
          final provider = context.read<OrderProvider>();
          if (provider.memberPoints == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pilih member untuk menukar poin')),
            );
            return;
          }
          showDialog<void>(
            context: context,
            builder: (_) => _LoyaltyPointDialog(provider: provider),
          );
        },
      ),
      _Action(
        icon: Icons.hourglass_empty_rounded,
        label: 'Pending',
        badgeNotifier: pendingCountNotifier,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PesananPendingPage()),
        ),
      ),
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
  const _Action({
    required this.icon,
    required this.label,
    this.onTap,
    this.badgeNotifier,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final ValueListenable<int>? badgeNotifier;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  static const double _box = 48;
  static const double _labelHeight = 34;

  final _Action action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _box,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
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
              if (action.badgeNotifier != null)
                Positioned(
                  top: -5,
                  right: -5,
                  child: ValueListenableBuilder<int>(
                    valueListenable: action.badgeNotifier!,
                    builder: (_, count, _) => count > 0
                        ? _BadgeCircle(count: count)
                        : const SizedBox.shrink(),
                  ),
                )
            ],
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

// ── Badge circle ─────────────────────────────────────────────────────────────

class _BadgeCircle extends StatelessWidget {
  const _BadgeCircle({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        '$count',
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.onError,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
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

// ── Split Bill dialog ─────────────────────────────────────────────────────────

class _SplitBillDialog extends StatefulWidget {
  const _SplitBillDialog({required this.items});

  final List<OrderItem> items;

  @override
  State<_SplitBillDialog> createState() => _SplitBillDialogState();
}

class _SplitBillDialogState extends State<_SplitBillDialog> {
  final Set<String> _selected = {};

  static String _fmt(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.35,
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
                    Text(
                      'Split Bill',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
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
            // Items
            ColoredBox(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.items.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),
                    _SplitBillItem(
                      item: widget.items[i],
                      selected: _selected.contains(widget.items[i].productId),
                      onTap: () => setState(() {
                        final id = widget.items[i].productId;
                        if (_selected.contains(id)) {
                          _selected.remove(id);
                        } else {
                          _selected.add(id);
                        }
                      }),
                      formatNum: _fmt,
                    ),
                  ],
                ],
              ),
            ),
            // Footer
            ColoredBox(
              color: AppColors.primary,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
                        child: Text(
                          'BATAL',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _selected.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(_selected.toList()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
                        child: Text(
                          'PILIH',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: _selected.isEmpty
                                ? AppColors.onPrimary.withValues(alpha: 0.4)
                                : AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
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

class _SplitBillItem extends StatelessWidget {
  const _SplitBillItem({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.formatNum,
  });

  final OrderItem item;
  final bool selected;
  final VoidCallback onTap;
  final String Function(double) formatNum;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: selected
                  ? const Icon(Icons.check, color: AppColors.onPrimary, size: 16)
                  : null,
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                '${item.quantity}x ${item.name}',
                style: AppTypography.textTheme.bodyMedium,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  formatNum(item.subtotal),
                  style: AppTypography.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loyalty reward model ──────────────────────────────────────────────────────

enum _RewardType { discount, freeItem }

class _LoyaltyReward {
  const _LoyaltyReward({
    required this.rewardId,
    required this.type,
    required this.icon,
    required this.name,
    required this.pointCost,
    this.discountValue = 0,
    this.discountType = DiscountType.amount,
    this.freeItemProductId,
    this.freeItemName,
    this.freeItemUnitPrice,
  });

  /// Id reward di server, dipakai saat menukar poin.
  final int rewardId;
  final _RewardType type;
  final IconData icon;
  final String name;
  final int pointCost;
  final double discountValue;
  final DiscountType discountType;
  final String? freeItemProductId;
  final String? freeItemName;
  final double? freeItemUnitPrice;

  /// Memetakan reward dari server ke bentuk yang dipakai layar ini.
  factory _LoyaltyReward.fromModel(LoyaltyRewardModel m) => _LoyaltyReward(
        rewardId: m.rewardId,
        type: m.isProdukGratis ? _RewardType.freeItem : _RewardType.discount,
        icon: m.isProdukGratis
            ? Icons.card_giftcard_rounded
            : Icons.local_fire_department_rounded,
        name: m.nama,
        pointCost: m.poin,
        discountValue: m.diskonNilai ?? 0,
        discountType: m.diskonTipe == 'percent'
            ? DiscountType.percent
            : DiscountType.amount,
        freeItemProductId: m.menuId?.toString(),
        freeItemName: m.namaMenu,
        freeItemUnitPrice: m.hargaMenu,
      );
}

// ── Loyalty Point dialog ──────────────────────────────────────────────────────

class _LoyaltyPointDialog extends StatefulWidget {
  const _LoyaltyPointDialog({required this.provider});

  final OrderProvider provider;

  @override
  State<_LoyaltyPointDialog> createState() => _LoyaltyPointDialogState();
}

class _LoyaltyPointDialogState extends State<_LoyaltyPointDialog> {
  final _datasource = LoyaltyRemoteDatasource();
  List<_LoyaltyReward> _rewards = const [];
  bool _memuat = true;
  bool _menukar = false;

  @override
  void initState() {
    super.initState();
    _muatRewards();
  }

  /// Katalog reward diambil dari server, menggantikan daftar hardcoded yang
  /// sebelumnya menunjuk produk yang tidak ada di database.
  Future<void> _muatRewards() async {
    try {
      final rows = await _datasource.fetchRewards();
      if (!mounted) return;
      setState(() => _rewards = rows.map(_LoyaltyReward.fromModel).toList());
    } on ApiException {
      // Biarkan daftar kosong; dialog tetap menampilkan sisa poin.
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  /// Menukar poin di server lebih dulu, baru menerapkan efeknya ke pesanan.
  /// Urutan ini penting supaya poin tidak terlanjur berkurang di layar padahal
  /// server menolak.
  Future<void> _tukar(_LoyaltyReward reward) async {
    if (_menukar) return;
    final provider = widget.provider;
    final memberId = provider.memberId;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (memberId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Pilih member terlebih dahulu')),
      );
      return;
    }

    setState(() => _menukar = true);
    try {
      await _datasource.redeem(memberId: memberId, rewardId: reward.rewardId);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menukar = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (reward.type == _RewardType.freeItem) {
      provider.redeemFreeItem(
        name: reward.name,
        pointCost: reward.pointCost,
        item: OrderItem(
          productId: reward.freeItemProductId ?? '',
          name: reward.freeItemName ?? reward.name,
          unitPrice: reward.freeItemUnitPrice ?? 0,
          quantity: 1,
          note: '** REDEEM',
        ),
        displayValue: reward.freeItemUnitPrice ?? 0,
      );
    } else {
      provider.redeemReward(
        reward.name,
        reward.pointCost,
        reward.discountValue,
        reward.discountType,
      );
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final currentPoints = provider.memberPoints ?? 0;
    final activeReward = provider.redeemRewardName;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.onPrimary, size: 22),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'Loyalty Point',
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
            // Body
            ColoredBox(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: activeReward != null
                        ? () {
                            provider.removeRedemption();
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x4,
                        vertical: AppSpacing.x3,
                      ),
                      child: Text(
                        '[Hapus Penukaran Saat Ini]',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: activeReward != null
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  if (_memuat)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.x4),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    for (final reward in _rewards)
                      _LoyaltyRewardTile(
                        reward: reward,
                        isSelected: activeReward == reward.name,
                        canAfford: currentPoints >= reward.pointCost,
                        onTap: currentPoints >= reward.pointCost && !_menukar
                            ? () => _tukar(reward)
                            : null,
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

class _LoyaltyRewardTile extends StatelessWidget {
  const _LoyaltyRewardTile({
    required this.reward,
    required this.isSelected,
    required this.canAfford,
    required this.onTap,
  });

  final _LoyaltyReward reward;
  final bool isSelected;
  final bool canAfford;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: canAfford ? const Color(0xFF6B5800) : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Icon(reward.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: canAfford
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${reward.pointCost} Pts',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: canAfford
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
