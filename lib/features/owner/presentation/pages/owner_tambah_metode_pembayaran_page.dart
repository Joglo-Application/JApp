import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class TambahMetodePembayaranResult {
  const TambahMetodePembayaranResult({required this.nama});

  final String nama;
}

const _iconOptions = [
  Icons.qr_code_scanner_rounded,
  Icons.credit_card_rounded,
  Icons.paid_rounded,
  Icons.payments_rounded,
  Icons.payment_rounded,
  Icons.handshake_rounded,
  Icons.diamond_rounded,
];

class OwnerTambahMetodePembayaranPage extends StatefulWidget {
  const OwnerTambahMetodePembayaranPage({super.key});

  @override
  State<OwnerTambahMetodePembayaranPage> createState() =>
      _OwnerTambahMetodePembayaranPageState();
}

class _OwnerTambahMetodePembayaranPageState
    extends State<OwnerTambahMetodePembayaranPage> {
  final _namaController = TextEditingController();
  IconData _selectedIcon = _iconOptions[0];

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconPicker(),
                    const SizedBox(height: AppSpacing.x4),
                    const Divider(color: AppColors.outlineVariant),
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      'Nama',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    _NameInput(controller: _namaController),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Tambah',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: AppRadius.full,
            child: const Icon(Icons.close_rounded, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPicker() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Icon',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _iconOptions
                .map(
                  (icon) => _IconOption(
                    icon: icon,
                    selected: _selectedIcon == icon,
                    onTap: () => setState(() => _selectedIcon = icon),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return GestureDetector(
      onTap: _onTambah,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
        color: Colors.green.shade600,
        alignment: Alignment.center,
        child: Text(
          'Tambah',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _onTambah() {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) return;
    context.pop(TambahMetodePembayaranResult(nama: nama));
  }
}

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerHighest,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Icon(
          icon,
          color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          size: 22,
        ),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      inputFormatters: [_UpperCaseFormatter()],
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
