import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'owner_edit_voucher_page.dart';
import 'owner_tambah_voucher_page.dart';

class OwnerDiskonVoucherPage extends StatefulWidget {
  const OwnerDiskonVoucherPage({super.key});

  @override
  State<OwnerDiskonVoucherPage> createState() => _OwnerDiskonVoucherPageState();
}

class _OwnerDiskonVoucherPageState extends State<OwnerDiskonVoucherPage> {
  final List<_VoucherData> _vouchers = [
    const _VoucherData(
      nama: 'PROMO MEI',
      tanggal: '13 Agustus 2025',
      kode: 'PROMOMEI1',
      diskon: '5%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x4,
              ),
              child: Row(
                children: [
                  Text(
                    'Buat Voucher',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  _TambahButton(onTap: _onTambah),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
                itemCount: _vouchers.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.x3),
                itemBuilder: (_, i) => _VoucherCard(
                  voucher: _vouchers[i],
                  onEdit: () => _onEdit(i),
                ),
              ),
            ),
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
            'Diskon & Voucher',
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

  Future<void> _onEdit(int index) async {
    final v = _vouchers[index];
    final deleted = await context.push<bool>(
      AppRoutes.ownerEditVoucher,
      extra: VoucherEditArgs(
        index: index,
        kode: v.kode,
        nama: v.nama,
        diskon: v.diskon,
        tanggal: v.tanggal,
      ),
    );
    if (deleted == true && mounted) {
      setState(() => _vouchers.removeAt(index));
    }
  }

  Future<void> _onTambah() async {
    final result = await context.push<TambahVoucherResult>(
      AppRoutes.ownerTambahVoucher,
    );
    if (result == null || !mounted) return;
    setState(() {
      _vouchers.add(_VoucherData(
        nama: result.nama,
        tanggal: result.tanggalAktif,
        kode: result.kode,
        diskon: result.diskonDisplay,
      ));
    });
  }
}

class _TambahButton extends StatelessWidget {
  const _TambahButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 20),
              const SizedBox(width: AppSpacing.x1),
              Text(
                'Tambah',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoucherData {
  const _VoucherData({
    required this.nama,
    required this.tanggal,
    required this.kode,
    required this.diskon,
  });

  final String nama;
  final String tanggal;
  final String kode;
  final String diskon;
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({required this.voucher, required this.onEdit});

  final _VoucherData voucher;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Row(
              children: [
                Text(
                  '${voucher.nama}  -  ${voucher.tanggal}',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    'Edit',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VoucherField(label: 'Kode', value: voucher.kode),
                const SizedBox(height: AppSpacing.x2),
                _VoucherField(label: 'Diskon', value: voucher.diskon),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherField extends StatelessWidget {
  const _VoucherField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurface,
    );

    return Row(
      children: [
        SizedBox(width: 64, child: Text(label, style: style)),
        Text('  -  ', style: style),
        Text(value, style: style),
      ],
    );
  }
}
