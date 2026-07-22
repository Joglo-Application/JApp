import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../spv/presentation/widgets/navigation/spv_drawer.dart';
import '../providers/order_provider.dart';
import '../widgets/order_panel/order_panel.dart';
import '../widgets/navigation/pos_drawer.dart';
import '../widgets/product_panel/product_panel.dart';
import 'payment_page.dart';
import 'pesanan_pending_page.dart';

const double _kExpandedBreakpoint = 800;

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  // Disimpan di didChangeDependencies agar bisa dipakai di dispose(), saat
  // context sudah tidak boleh dipakai untuk lookup provider.
  OrderProvider? _order;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _order = context.read<OrderProvider>();
  }

  @override
  void dispose() {
    // Kasir pindah ke fitur lain dengan cart masih terisi → auto-simpan ke
    // Pending (POS adalah GoRoute biasa, jadi dispose() = benar-benar keluar
    // dari POS; sub-flow seperti Payment/Pilih Meja hanya di-push sehingga POS
    // tetap mounted dan tidak memicu ini). Dijadwalkan setelah frame agar tidak
    // memanggil notifyListeners saat subtree POS sedang dibongkar.
    final order = _order;
    if (order != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        order.autoHoldToPending().then((saved) {
          if (saved) refreshPendingOrders();
        });
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kasir & SPV sama-sama landing di POS, tapi menu drawer-nya beda per role.
    final isSupervisor = context.select<AuthProvider, bool>(
      (a) => a.user?.role == 'supervisor',
    );

    return Scaffold(
      drawer: isSupervisor ? const SpvDrawer() : const PosDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= _kExpandedBreakpoint) {
              return const _ExpandedLayout();
            }
            return const _CompactLayout();
          },
        ),
      ),
    );
  }
}

Future<void> _goToPayment(BuildContext context) async {
  final order = context.read<OrderProvider>();
  if (order.isEmpty) return;

  // Dine-In wajib "Kirim ke Dapur" dulu (pesanan diparkir di meja & diambil
  // ulang lewat "Lihat Pesanan" untuk dibayar). Non-Dine-In boleh langsung
  // bayar — pesanannya dibuat & dikirim ke dapur saat pembayaran selesai.
  if (order.effectiveOrderType == OrderType.dineIn && !order.isSentToKitchen) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.send_rounded),
        title: const Text('Kirim ke Dapur dulu'),
        content: const Text(
          'Pesanan Dine-In harus dikirim ke dapur terlebih dahulu sebelum '
          'melakukan pembayaran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
    return;
  }

  // Kalau pesanan sudah dikirim ke dapur, minta konfirmasi dulu sebelum
  // lanjut bayar — item sudah diproses/keluar dari dapur jadi kasir perlu
  // memastikan tidak ada perubahan pesanan lagi.
  if (order.isSentToKitchen) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmPaymentDialog(),
    );
    if (confirmed != true) return;
  }

  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const PaymentPage()),
  );
}

// ── Confirm payment dialog ────────────────────────────────────────────────

class _ConfirmPaymentDialog extends StatelessWidget {
  const _ConfirmPaymentDialog();

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
                          'Apakah kamu yakin?',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        Text(
                          'Semua pesanan sudah keluar dari dapur?',
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

class _ExpandedLayout extends StatelessWidget {
  const _ExpandedLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: OrderPanel(onCheckout: () => _goToPayment(context))),
        const Expanded(child: ProductPanel()),
      ],
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Column(
      children: [
        const Expanded(child: ProductPanel()),
        SizedBox(
          height: screenHeight * 0.42,
          child: OrderPanel(onCheckout: () => _goToPayment(context)),
        ),
      ],
    );
  }
}
