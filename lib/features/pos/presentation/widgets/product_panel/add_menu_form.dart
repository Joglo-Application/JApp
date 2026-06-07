import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../domain/entities/category.dart';
import '../../providers/menu_provider.dart';

/// Form for creating a new persistent menu item (name + category + price),
/// saved to the backend via [MenuProvider.createMenu]. Part of menu management.
class AddMenuForm extends StatefulWidget {
  const AddMenuForm({super.key, this.onCreated});

  /// Called after a menu is successfully created (e.g. to switch back to the
  /// Produk grid so the new item is visible).
  final VoidCallback? onCreated;

  @override
  State<AddMenuForm> createState() => _AddMenuFormState();
}

class _AddMenuFormState extends State<AddMenuForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _categoryId;

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

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final harga = int.tryParse(_priceController.text.replaceAll(RegExp(r'\D'), ''));
    final kategori = _categoryId;

    if (name.isEmpty || harga == null || harga <= 0 || kategori == null) {
      _toast('Lengkapi nama, kategori, dan harga terlebih dahulu.');
      return;
    }

    final menu = context.read<MenuProvider>();
    final ok = await menu.createMenu(
      namaMenu: name,
      kategori: kategori,
      harga: harga,
    );
    if (!mounted) return;

    if (ok) {
      _toast('Menu "$name" berhasil ditambahkan.');
      _nameController.clear();
      _priceController.clear();
      setState(() => _categoryId = null);
      widget.onCreated?.call();
    } else {
      _toast(menu.submitError ?? 'Gagal menambah menu.');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

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
              _CategoryField(
                categories: menu.categories,
                value: _categoryId,
                onChanged: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: AppSpacing.x6),
              _PriceField(controller: _priceController),
              const SizedBox(height: AppSpacing.x6),
              AppButton(
                label: 'Tambahkan Menu',
                onPressed: _submit,
                isLoading: menu.isSubmitting,
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
              hintText: 'Nama menu',
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

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.sell_outlined,
            color: AppColors.onPrimary,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.outline),
              ),
            ),
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Text(
                categories.isEmpty ? 'Tidak ada kategori' : 'Pilih kategori',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
              ),
              items: [
                for (final c in categories)
                  DropdownMenuItem<String>(value: c.id, child: Text(c.name)),
              ],
              onChanged: categories.isEmpty ? null : onChanged,
            ),
          ),
        ),
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
