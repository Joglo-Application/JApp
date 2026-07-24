import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/id_generator.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../domain/entities/order_item.dart';
import '../../providers/order_provider.dart';
import 'form_field_widgets.dart';

class CustomItemForm extends StatefulWidget {
  const CustomItemForm({super.key});

  @override
  State<CustomItemForm> createState() => _CustomItemFormState();
}

class _CustomItemFormState extends State<CustomItemForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  int _quantity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  String get _avatarLetter {
    final text = _nameController.text.trim();
    return text.isEmpty ? 'A' : text[0].toUpperCase();
  }

  /// Ketik langsung di field qty — perbarui [_quantity] saat angkanya valid (≥1).
  void _onQtyText(String v) {
    final n = int.tryParse(v);
    setState(() {
      if (n != null && n >= 1) _quantity = n;
    });
  }

  /// Tombol +/- — ubah [_quantity] lalu sinkronkan teks field (kursor di akhir).
  void _changeQty(int delta) {
    final n = (_quantity + delta).clamp(1, 9999);
    setState(() => _quantity = n);
    _qtyController.value = TextEditingValue(
      text: '$n',
      selection: TextSelection.collapsed(offset: '$n'.length),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll(',', ''));
    final qty = (int.tryParse(_qtyController.text) ?? _quantity).clamp(1, 9999);
    if (name.isEmpty || price == null || price <= 0) return;

    context.read<OrderProvider>().addOrIncrement(
          OrderItem(
            productId: IdGenerator.generate(),
            name: name,
            unitPrice: price,
            quantity: qty,
          ),
        );

    _nameController.clear();
    _priceController.clear();
    _qtyController.text = '1';
    setState(() => _quantity = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lg,
          ),
          padding: const EdgeInsets.all(AppSpacing.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _NameField(
                controller: _nameController,
                avatarLetter: _avatarLetter,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.x6),
              FormPriceField(controller: _priceController),
              const SizedBox(height: AppSpacing.x6),
              _QuantityRow(
                controller: _qtyController,
                onChanged: _onQtyText,
                onDecrement: () => _changeQty(-1),
                onIncrement: () => _changeQty(1),
              ),
              const SizedBox(height: AppSpacing.x6),
              AppButton(
                label: 'Tambahkan Item Custom',
                onPressed: _submit,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.avatarLetter,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String avatarLetter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FormAvatarBadge(letter: avatarLetter),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Nama item',
              hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.x2,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        _DropdownButton(controller: controller, onSelected: onChanged),
      ],
    );
  }
}

const List<String> _kCustomItemTemplates = [
  'Barang Titip Jual',
  'Sambel Ulek',
  'Sambel Ijo',
];

class _DropdownButton extends StatelessWidget {
  const _DropdownButton({
    required this.controller,
    required this.onSelected,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSelected;

  void _showPicker(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.primary,
        shape: AppRadius.toShape(AppRadius.lg),
        child: SizedBox(
          width: 360,
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
                      Icons.receipt_long_rounded,
                      color: AppColors.onPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Text(
                        'Custom',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.onPrimary,
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.x4),
                  shrinkWrap: true,
                  children: _kCustomItemTemplates
                      .map(
                        (name) => _CustomItemTile(
                          label: name,
                          onTap: () => Navigator.of(ctx).pop(name),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((selected) {
      if (selected != null) {
        controller.text = selected;
        onSelected(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.sm,
        ),
        child: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.onPrimary,
          size: 20,
        ),
      ),
    );
  }
}

class _CustomItemTile extends StatelessWidget {
  const _CustomItemTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.controller,
    required this.onChanged,
    required this.onDecrement,
    required this.onIncrement,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.x2),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        _StepperButton(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: AppSpacing.x2),
        _StepperButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: AppRadius.sm,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}
