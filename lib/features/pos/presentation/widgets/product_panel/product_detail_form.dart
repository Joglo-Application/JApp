import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/product.dart';
import '../../providers/order_provider.dart';

class ProductDetailForm extends StatefulWidget {
  const ProductDetailForm({
    super.key,
    required this.product,
    required this.onCancel,
    this.existingItem,
  });

  final Product product;
  final VoidCallback onCancel;
  final OrderItem? existingItem;

  @override
  State<ProductDetailForm> createState() => _ProductDetailFormState();
}

class _ProductDetailFormState extends State<ProductDetailForm> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _noteCtrl;

  late int _qty;
  late DiscountType _discountType;
  String? _promoLabel;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    _qty = existing?.quantity ?? 1;
    _discountType = existing?.discountType ?? DiscountType.amount;
    _priceCtrl = TextEditingController(
      text: (existing?.unitPrice ?? widget.product.price).toStringAsFixed(0),
    );
    _discountCtrl = TextEditingController(
      text: (existing?.discount ?? 0).toStringAsFixed(0),
    );
    _noteCtrl = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _applyPromo(DiscountPromo promo) {
    setState(() {
      _promoLabel = promo.name;
      _discountType = promo.discountType;
      _discountCtrl.text = promo.discount.toStringAsFixed(0);
    });
  }

  void _save() {
    final price =
        double.tryParse(_priceCtrl.text.replaceAll('.', '').replaceAll(',', '')) ??
            widget.product.price;
    final discount = double.tryParse(_discountCtrl.text) ?? 0.0;
    final note = _noteCtrl.text.trim();

    final newItem = OrderItem(
      productId: widget.product.id,
      name: widget.product.name,
      unitPrice: price,
      quantity: _qty,
      imageUrl: widget.product.imageUrl,
      discount: discount,
      discountType: _discountType,
      note: note,
      promoName: _promoLabel,
    );

    final provider = context.read<OrderProvider>();
    if (widget.existingItem != null) {
      provider.replaceItem(newItem);
    } else {
      provider.addFromForm(newItem);
    }

    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailHeader(product: widget.product, onClose: widget.onCancel),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              AppSpacing.x4,
              AppSpacing.x4,
              AppSpacing.x2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HargaSection(controller: _priceCtrl, product: widget.product),
                const SizedBox(height: AppSpacing.x4),
                _QtySection(
                  qty: _qty,
                  onDecrement: () {
                    if (_qty > 1) setState(() => _qty--);
                  },
                  onIncrement: () => setState(() => _qty++),
                ),
                const SizedBox(height: AppSpacing.x4),
                _DiskonSection(
                  controller: _discountCtrl,
                  discountType: _discountType,
                  onTypeChanged: (t) => setState(() => _discountType = t),
                  promoLabel: _promoLabel,
                  onPromoSelected: _applyPromo,
                ),
                const SizedBox(height: AppSpacing.x4),
                _CatatanSection(controller: _noteCtrl),
                const SizedBox(height: AppSpacing.x6),
                _BatalButton(onPressed: widget.onCancel),
                const SizedBox(height: AppSpacing.x4),
              ],
            ),
          ),
        ),
        _SaveBar(onSave: _save),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.product, required this.onClose});

  final Product product;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x4,
        AppSpacing.x4,
        AppSpacing.x2,
        AppSpacing.x4,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.sm,
            ),
            clipBehavior: Clip.antiAlias,
            child: product.imageUrl != null
                ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                : const Icon(
                    Icons.restaurant_outlined,
                    size: 26,
                    color: AppColors.onSurfaceVariant,
                  ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Text(
              product.name,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.onPrimary,
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Form sections ─────────────────────────────────────────────────────────────

class _HargaSection extends StatelessWidget {
  const _HargaSection({required this.controller, required this.product});

  final TextEditingController controller;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Harga'),
        const SizedBox(height: AppSpacing.x2),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _valueStyle,
          decoration: _fieldDecoration(
            hintText: CurrencyFormatter.format(product.price),
          ),
        ),
      ],
    );
  }
}

class _QtySection extends StatelessWidget {
  const _QtySection({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Qty'),
        const SizedBox(height: AppSpacing.x2),
        Row(
          children: [
            Expanded(
              child: TextField(
                readOnly: true,
                controller: TextEditingController(text: '$qty'),
                style: _valueStyle,
                decoration: _fieldDecoration(),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            _StepButton(icon: Icons.remove, onTap: onDecrement),
            const SizedBox(width: AppSpacing.x2),
            _StepButton(icon: Icons.add, onTap: onIncrement),
          ],
        ),
      ],
    );
  }
}

class _DiskonSection extends StatelessWidget {
  const _DiskonSection({
    required this.controller,
    required this.discountType,
    required this.onTypeChanged,
    required this.onPromoSelected,
    this.promoLabel,
  });

  final TextEditingController controller;
  final DiscountType discountType;
  final ValueChanged<DiscountType> onTypeChanged;
  final ValueChanged<DiscountPromo> onPromoSelected;
  final String? promoLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _label(
                promoLabel != null ? 'Diskon - $promoLabel' : 'Diskon',
              ),
            ),
            _OutlineButton(
              label: 'Diskon Pesanan',
              onTap: () => showDialog(
                context: context,
                builder: (_) => DiskonPesananDialog(
                  onPromoSelected: onPromoSelected,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: _valueStyle,
                decoration: _fieldDecoration(
                  prefixText: discountType == DiscountType.percent ? '% ' : 'Rp ',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            _TypeToggle(
              selected: discountType == DiscountType.amount,
              label: 'Uang',
              onTap: () => onTypeChanged(DiscountType.amount),
            ),
            const SizedBox(width: AppSpacing.x2),
            _TypeToggle(
              selected: discountType == DiscountType.percent,
              label: 'Persen',
              onTap: () => onTypeChanged(DiscountType.percent),
            ),
          ],
        ),
      ],
    );
  }
}

class _CatatanSection extends StatelessWidget {
  const _CatatanSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Catatan'),
        const SizedBox(height: AppSpacing.x2),
        TextField(
          controller: controller,
          maxLines: 2,
          style: _valueStyle,
          decoration: _fieldDecoration(hintText: 'Tambahkan catatan…'),
        ),
      ],
    );
  }
}

// ── Bottom buttons ────────────────────────────────────────────────────────────

class _BatalButton extends StatelessWidget {
  const _BatalButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.close_rounded, size: 16),
        label: const Text('Batal'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.onPrimary,
          backgroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x2,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.15),
        border: Border(
          top: BorderSide(color: AppColors.onPrimary.withValues(alpha: 0.2)),
        ),
      ),
      child: InkWell(
        onTap: onSave,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Text(
            'SIMPAN',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.6)),
          borderRadius: AppRadius.sm,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.onPrimary, size: 18),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.onPrimary : Colors.transparent,
          border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.6)),
          borderRadius: AppRadius.sm,
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.primary : AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.6)),
          borderRadius: AppRadius.sm,
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _label(String text) => Text(
      text,
      style: AppTypography.textTheme.labelMedium?.copyWith(
        color: AppColors.onPrimary.withValues(alpha: 0.75),
      ),
    );

const TextStyle _valueStyle = TextStyle(
  color: AppColors.onPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

InputDecoration _fieldDecoration({String? hintText, String? prefixText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: AppColors.onPrimary.withValues(alpha: 0.4)),
    prefixText: prefixText,
    prefixStyle: const TextStyle(
      color: AppColors.onPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    filled: false,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.onPrimary.withValues(alpha: 0.6)),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.onPrimary, width: 2),
    ),
  );
}

// ── Diskon Pesanan Dialog ─────────────────────────────────────────────────────

class DiscountPromo {
  const DiscountPromo({
    required this.name,
    required this.discount,
    required this.discountType,
  });

  final String name;
  final double discount;
  final DiscountType discountType;
}

class DiskonPesananDialog extends StatefulWidget {
  const DiskonPesananDialog({
    super.key,
    required this.onPromoSelected,
    this.title = 'Diskon Item',
    this.onOpenInput,
  });

  final ValueChanged<DiscountPromo> onPromoSelected;
  final String title;
  final VoidCallback? onOpenInput;

  @override
  State<DiskonPesananDialog> createState() => _DiskonPesananDialogState();
}

class _DiskonPesananDialogState extends State<DiskonPesananDialog> {
  final _voucherCtrl = TextEditingController();

  @override
  void dispose() {
    _voucherCtrl.dispose();
    super.dispose();
  }

  void _selectPromo(DiscountPromo promo) {
    widget.onPromoSelected(promo);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: AppColors.primary,
      shape: AppRadius.toShape(AppRadius.lg),
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x4,
                AppSpacing.x2,
                AppSpacing.x4,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.discount_outlined,
                    color: AppColors.onPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.onPrimary,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            if (widget.onOpenInput != null) ...[
              // InkWell(
              //   onTap: () {
              //     Navigator.of(context).pop();
              //     widget.onOpenInput!();
              //   },
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: AppSpacing.x4,
              //       vertical: AppSpacing.x3,
              //     ),
              //     child: Text(
              //       '[Masukan Jumlah/Persen Diskon]',
              //       style: AppTypography.textTheme.bodyMedium?.copyWith(
              //         color: AppColors.onPrimary.withValues(alpha: 0.55),
              //       ),
              //     ),
              //   ),
              // ),
              // Divider(height: 1, color: AppColors.onPrimary.withValues(alpha: 0.2)),
                _PromoTile(
              name: '[Masukkan Jumlah/Persen Diskon]',
              description: '',
              onTap: () {
                     Navigator.of(context).pop();
                  widget.onOpenInput!();
              },
            ),
            ],
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
            //   child: TextField(
            //     controller: _voucherCtrl,
            //     style: _valueStyle,
            //     decoration: _fieldDecoration(hintText: '[Masukkan Kode Voucher]'),
            //   ),
            // ),
              _PromoTile(
              name: '[Masukkan Kode VOucher]',
              description: '',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.x3),
            Divider(height: 1, color: AppColors.onPrimary.withValues(alpha: 0.2)),
            _PromoTile(
              name: 'PROMO MEI (PROMOMEI1)',
              description: 'Diskon. 5%',
              onTap: () => _selectPromo(const DiscountPromo(
                name: 'PROMO MEI',
                discount: 5,
                discountType: DiscountType.percent,
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({
    required this.name,
    required this.description,
    required this.onTap,
  });

  final String name;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
