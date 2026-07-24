import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../domain/entities/order_item.dart';
import '../../providers/order_provider.dart';
import '../shared/pin_supervisor_dialog.dart';
import 'diskon_input.dart';

class OrderSummaryTotals extends StatelessWidget {
  const OrderSummaryTotals({super.key});

  /// Ketuk baris "Pajak" → minta PIN Supervisor, lalu buka form Pajak (persen
  /// atau nominal Rupiah). Nilainya disimpan sebagai default toko di server
  /// (berlaku untuk semua pesanan & bertahan setelah reload).
  Future<void> _editPajakWithApproval(BuildContext context) async {
    final order = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const PinSupervisorDialog(),
    );
    if (pin == null || !context.mounted) return;

    // Form hanya mengumpulkan nilai + tipe; penyimpanan (butuh PIN) dilakukan
    // setelah form ditutup.
    double? nilai;
    DiscountType? tipe;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DiskonInputPage(
        title: 'Tipe Pajak',
        initialType: order.pajakType,
        onSave: (v, t) {
          nilai = v;
          tipe = t;
        },
      ),
    );
    if (nilai == null || tipe == null) return; // dibatalkan

    final ok = await order.savePajakSetting(tipe!, nilai!, pin);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Pajak diperbarui' : (order.submitError ?? 'Gagal memperbarui pajak'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final serviceRate = order.serviceRate;

    final namaKasir = context.select<AuthProvider, String>(
      (auth) => auth.user?.namaUser ?? '-',
    );

    // Label Pajak: tampilkan '%' untuk tipe persen; untuk nominal Rupiah beri
    // penanda "(Rp)" agar tidak terlihat kosong (nominalnya tampil di kanan).
    final pajakLabel = order.pajakType == DiscountType.percent
        ? 'Pajak : ${order.pajakValue.toStringAsFixed(0)}%'
        : 'Pajak (Rp) :';

    final rows = <({String label, String value, VoidCallback? onTap})>[
      if (order.orderDiscountAmount > 0)
        (
          label: order.orderPromoName != null
              ? 'Diskon  [${order.orderPromoName}] :'
              : 'Diskon :',
          value: '-${CurrencyFormatter.format(order.orderDiscountAmount)}',
          onTap: null,
        ),
      (
        label: 'Subtotal :',
        value: CurrencyFormatter.format(order.subtotal),
        onTap: null,
      ),
      (
        label: 'Biaya Layanan : ${(serviceRate * 100).toStringAsFixed(0)}%',
        value: CurrencyFormatter.format(order.subtotal * serviceRate),
        onTap: null,
      ),
      (
        label: pajakLabel,
        value: CurrencyFormatter.format(order.pajakAmount),
        onTap: () => _editPajakWithApproval(context),
      ),
      if (order.redeemedPointCost != null)
        (
          label: 'Ditebus : -${order.redeemedPointCost}',
          value: '-${CurrencyFormatter.format(order.redeemDisplayValue)}',
          onTap: null,
        ),
      if (order.memberPoints != null && order.earnedPoints > 0)
        (label: 'Point :', value: '+${order.earnedPoints}', onTap: null),
      if (order.orderNote.isNotEmpty)
        (label: 'Catatan :  ${order.orderNote}', value: '', onTap: null),
      (label: 'Jumlah Item : ${order.totalQty}', value: '', onTap: null),
      (label: 'Dilayani Oleh : $namaKasir', value: '', onTap: null),
    ];

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          _SummaryRow(
            label: rows[i].label,
            value: rows[i].value,
            shaded: i.isOdd,
            onTap: rows[i].onTap,
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.shaded,
    this.onTap,
  });

  final String label;
  final String value;
  final bool shaded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;
    // Baris yang bisa diketuk (mis. Pajak → ubah tarif) diberi warna primary
    // + ikon edit sebagai petunjuk.
    final labelColor = tappable ? AppColors.primary : AppColors.onSurface;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: labelColor,
              fontWeight: tappable ? FontWeight.w600 : null,
            ),
          ),
          if (tappable) ...[
            const SizedBox(width: AppSpacing.x1),
            const Icon(Icons.edit_rounded, size: 13, color: AppColors.primary),
          ],
          const Spacer(),
          if (value.isNotEmpty)
            Text(
              value,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );

    return ColoredBox(
      color: shaded ? AppColors.background : AppColors.surface,
      child: tappable
          ? InkWell(onTap: onTap, child: content)
          : content,
    );
  }
}
