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

class CustomItemForm extends StatefulWidget {
  const CustomItemForm({super.key});

  @override
  State<CustomItemForm> createState() => _CustomItemFormState();
}

class _CustomItemFormState extends State<CustomItemForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String get _avatarLetter {
    final text = _nameController.text.trim();
    return text.isEmpty ? 'A' : text[0].toUpperCase();
  }

  void _increment() => setState(() => _quantity++);

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll(',', ''));
    if (name.isEmpty || price == null || price <= 0) return;

    context.read<OrderProvider>().addOrIncrement(
          OrderItem(
            productId: IdGenerator.generate(),
            name: name,
            unitPrice: price,
            quantity: _quantity,
          ),
        );

    _nameController.clear();
    _priceController.clear();
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
              _PriceField(controller: _priceController),
              const SizedBox(height: AppSpacing.x6),
              _QuantityRow(
                quantity: _quantity,
                onDecrement: _decrement,
                onIncrement: _increment,
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
        _AvatarBadge(letter: avatarLetter),
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
        _DropdownButton(),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.sm,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTypography.textTheme.titleSmall?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DropdownButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CurrencyIcon(),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Harga',
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
      ],
    );
  }
}

class _CurrencyIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.attach_money_rounded,
        color: AppColors.onPrimary,
        size: 18,
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            controller: TextEditingController(text: '$quantity'),
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
