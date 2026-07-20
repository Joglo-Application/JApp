import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class LoyaltyDiskonResult {
  const LoyaltyDiskonResult({
    required this.points,
    required this.diskonDisplay,
    required this.tipe,
    required this.nilai,
  });

  final int points;
  final String diskonDisplay;

  /// `amount` atau `percent` — nilai terstruktur untuk dikirim ke server.
  final String tipe;
  final double nilai;
}

enum _DiskonType { nominal, persen }

class OwnerTambahLoyaltyDiskonPage extends StatefulWidget {
  const OwnerTambahLoyaltyDiskonPage({super.key});

  @override
  State<OwnerTambahLoyaltyDiskonPage> createState() =>
      _OwnerTambahLoyaltyDiskonPageState();
}

class _OwnerTambahLoyaltyDiskonPageState
    extends State<OwnerTambahLoyaltyDiskonPage> {
  final _pointController = TextEditingController();
  final _diskonController = TextEditingController();
  _DiskonType _diskonType = _DiskonType.nominal;

  @override
  void dispose() {
    _pointController.dispose();
    _diskonController.dispose();
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormField(
                      label: 'Besar Point',
                      child: _OutlinedInput(
                        controller: _pointController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    _FormField(
                      label: 'Jumlah Diskon',
                      child: Row(
                        children: [
                          Expanded(
                            child: _OutlinedInput(
                              controller: _diskonController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              prefix: _diskonType == _DiskonType.nominal
                                  ? 'IDR  '
                                  : null,
                              suffix: _diskonType == _DiskonType.persen
                                  ? '%'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x2),
                          _DiskonTypeButton(
                            icon: Icons.attach_money_rounded,
                            active: _diskonType == _DiskonType.nominal,
                            onTap: () =>
                                setState(() => _diskonType = _DiskonType.nominal),
                          ),
                          const SizedBox(width: AppSpacing.x2),
                          _DiskonTypeButton(
                            icon: Icons.percent_rounded,
                            active: _diskonType == _DiskonType.persen,
                            onTap: () =>
                                setState(() => _diskonType = _DiskonType.persen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(
              Icons.discount_rounded,
              color: AppColors.onError,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            'Diskon',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
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

  Widget _buildBottomBar() {
    return GestureDetector(
      onTap: _onTambah,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
        color: AppColors.tertiary,
        alignment: Alignment.center,
        child: Text(
          'Tambah',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.onTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _onTambah() {
    final points = int.tryParse(_pointController.text.trim()) ?? 0;
    final diskon = _diskonController.text.trim();
    if (points <= 0 || diskon.isEmpty) return;

    final diskonDisplay =
        _diskonType == _DiskonType.persen ? '$diskon%' : 'IDR $diskon';

    context.pop(LoyaltyDiskonResult(
      points: points,
      diskonDisplay: diskonDisplay,
      tipe: _diskonType == _DiskonType.persen ? 'percent' : 'amount',
      nilai: double.tryParse(diskon.replaceAll('.', '').replaceAll(',', '.')) ?? 0,
    ));
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        child,
      ],
    );
  }
}

class _OutlinedInput extends StatelessWidget {
  const _OutlinedInput({
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.suffix,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        prefixText: prefix,
        suffixText: suffix,
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

class _DiskonTypeButton extends StatelessWidget {
  const _DiskonTypeButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceContainerHighest,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          size: 22,
        ),
      ),
    );
  }
}
