import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class LoyaltyProdukGratisResult {
  const LoyaltyProdukGratisResult({
    required this.points,
    required this.productName,
    required this.qty,
  });

  final int points;
  final String productName;
  final int qty;
}

class OwnerTambahLoyaltyProdukGratisPage extends StatefulWidget {
  const OwnerTambahLoyaltyProdukGratisPage({super.key});

  @override
  State<OwnerTambahLoyaltyProdukGratisPage> createState() =>
      _OwnerTambahLoyaltyProdukGratisPageState();
}

class _OwnerTambahLoyaltyProdukGratisPageState
    extends State<OwnerTambahLoyaltyProdukGratisPage> {
  final _pointController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _productController = TextEditingController();
  String? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _qtyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pointController.dispose();
    _qtyController.dispose();
    _productController.dispose();
    super.dispose();
  }

  int get _qty => int.tryParse(_qtyController.text.trim()) ?? 1;

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Pilih ',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                            ),
                            children: [
                              TextSpan(
                                text: '$_qty',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' Produk'),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        Row(
                          children: [
                            Expanded(
                              child: _OutlinedInput(
                                controller: _productController,
                                readOnly: true,
                                hintText: _selectedProduct,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.x2),
                            _PilihProdukButton(onTap: _onPilihProduk),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    _FormField(
                      label: 'Qty Produk',
                      child: _OutlinedInput(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              color: AppColors.tertiary,
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.onTertiary,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            'Produk Gratis',
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

  Future<void> _onPilihProduk() async {
    final product = await context.push<String>(AppRoutes.ownerPilihProduk);
    if (product != null && mounted) {
      setState(() {
        _selectedProduct = product;
        _productController.text = product;
      });
    }
  }

  void _onTambah() {
    final points = int.tryParse(_pointController.text.trim()) ?? 0;
    final product = _selectedProduct;
    final qty = _qty;
    if (points <= 0 || product == null || qty <= 0) return;

    context.pop(LoyaltyProdukGratisResult(
      points: points,
      productName: product,
      qty: qty,
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
    this.readOnly = false,
    this.hintText,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        filled: readOnly,
        fillColor: readOnly ? AppColors.surfaceContainerHighest : null,
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

class _PilihProdukButton extends StatelessWidget {
  const _PilihProdukButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Text(
            '+ Pilih Produk',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
