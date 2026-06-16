import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

enum _TransaksiTab { pesanan, selesai, retur, dibatalkan }

class OwnerTransaksiListPage extends StatefulWidget {
  const OwnerTransaksiListPage({super.key});

  @override
  State<OwnerTransaksiListPage> createState() => _OwnerTransaksiListPageState();
}

class _OwnerTransaksiListPageState extends State<OwnerTransaksiListPage> {
  _TransaksiTab _tab = _TransaksiTab.pesanan;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
            _buildTabBar(),
            if (_tab == _TransaksiTab.selesai) _buildFilterBar(),
            const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
            Expanded(child: _buildTable()),
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
            'Transaksi',
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

  Widget _buildTabBar() {
    return Row(
      children: _TransaksiTab.values.map(_buildTabButton).toList(),
    );
  }

  Widget _buildTabButton(_TransaksiTab tab) {
    final isActive = _tab == tab;
    final label = switch (tab) {
      _TransaksiTab.pesanan => 'Pesanan',
      _TransaksiTab.selesai => 'Selesai',
      _TransaksiTab.retur => 'Retur',
      _TransaksiTab.dibatalkan => 'Dibatalkan',
    };

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadius.md,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: isActive ? AppColors.onPrimary : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 22),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: AppRadius.md,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
              child: TextField(
                controller: _searchController,
                style: AppTypography.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Cari',
                  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          const Icon(Icons.sort_rounded, size: 22),
          const SizedBox(width: AppSpacing.x3),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.md,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.onPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final rows = _placeholderRows;

    if (rows.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data.',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.outlineVariant,
      ),
      itemBuilder: (_, i) => _TransaksiRow(
        kode: rows[i].$1,
        tanggal: rows[i].$2,
        pelanggan: rows[i].$3,
        nominal: rows[i].$4,
      ),
    );
  }

  List<(String, String, String, String)> get _placeholderRows => switch (_tab) {
        _TransaksiTab.pesanan => [
            ('[Kode Pesanan]', '15 Agustus 2025', '-', 'IDR 40.000'),
          ],
        _TransaksiTab.selesai => [
            ('[Kode Pesanan]', '14 Agustus 2025', '-', 'IDR 80.000'),
            ('[Kode Pesanan]', '14 Agustus 2025', '-', 'IDR 20.000'),
            ('[Kode Pesanan]', '13 Agustus 2025', 'Langganan 01', 'IDR 120.000'),
            ('[Kode Pesanan]', '13 Agustus 2025', '-', 'IDR 90.000'),
          ],
        _TransaksiTab.retur => [
            ('[Kode Pesanan]', '15 Agustus 2025', '-', 'IDR 40.000'),
          ],
        _TransaksiTab.dibatalkan => [
            ('[Kode Pesanan]', '15 Agustus 2025', '-', 'IDR 40.000'),
          ],
      };
}

class _TransaksiRow extends StatelessWidget {
  const _TransaksiRow({
    required this.kode,
    required this.tanggal,
    required this.pelanggan,
    required this.nominal,
  });

  final String kode;
  final String tanggal;
  final String pelanggan;
  final String nominal;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(kode, style: style)),
          Expanded(flex: 3, child: Text(tanggal, style: style)),
          Expanded(flex: 3, child: Text(pelanggan, style: style)),
          Expanded(
            flex: 2,
            child: Text(nominal, style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
