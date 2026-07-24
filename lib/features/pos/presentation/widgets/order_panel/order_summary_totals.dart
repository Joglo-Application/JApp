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

  /// Ketuk baris tarif (Pajak / Biaya Layanan) → minta PIN Supervisor, lalu buka
  /// form (persen atau nominal Rupiah). Nilainya disimpan sebagai default toko
  /// di server (berlaku untuk semua pesanan & bertahan setelah reload).
  Future<void> _editTarif(
    BuildContext context, {
    required String title,
    required DiscountType initialType,
    required Future<bool> Function(DiscountType, double, String) save,
    required String labelSukses,
  }) async {
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
        title: title,
        initialType: initialType,
        onSave: (v, t) {
          nilai = v;
          tipe = t;
        },
      ),
    );
    if (nilai == null || tipe == null) return; // dibatalkan

    final ok = await save(tipe!, nilai!, pin);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? labelSukses : (order.submitError ?? 'Gagal memperbarui tarif'),
        ),
      ),
    );
  }

  // Label tarif: tampilkan nilainya inline — '%' untuk persen, nominal Rupiah
  // untuk amount — supaya konsisten (mis. "Pajak : 15%" / "Pajak : Rp 12.000").
  String _tarifLabel(String nama, DiscountType tipe, double value) =>
      tipe == DiscountType.percent
          ? '$nama : ${value.toStringAsFixed(0)}%'
          : '$nama : ${CurrencyFormatter.format(value)}';

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    final namaKasir = context.select<AuthProvider, String>(
      (auth) => auth.user?.namaUser ?? '-',
    );

    final pajakLabel = _tarifLabel('Pajak', order.pajakType, order.pajakValue);
    final layananLabel =
        _tarifLabel('Biaya Layanan', order.layananType, order.layananValue);

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
        label: layananLabel,
        value: CurrencyFormatter.format(order.serviceAmount),
        onTap: () => _editTarif(
          context,
          title: 'Tipe Biaya Layanan',
          initialType: order.layananType,
          save: order.saveLayananSetting,
          labelSukses: 'Biaya layanan diperbarui',
        ),
      ),
      (
        label: pajakLabel,
        value: CurrencyFormatter.format(order.pajakAmount),
        onTap: () => _editTarif(
          context,
          title: 'Tipe Pajak',
          initialType: order.pajakType,
          save: order.savePajakSetting,
          labelSukses: 'Pajak diperbarui',
        ),
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
