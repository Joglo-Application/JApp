import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/navigation/owner_drawer.dart';

class OwnerPengaturanPage extends StatefulWidget {
  const OwnerPengaturanPage({super.key});

  @override
  State<OwnerPengaturanPage> createState() => _OwnerPengaturanPageState();
}

class _OwnerPengaturanPageState extends State<OwnerPengaturanPage> {
  bool _ringkasanOtomatis = true;
  bool _cetakOtomatis = false;
  bool _notifikasiPesanan = true;
  bool _notifikasiStok = true;
  bool _notifikasiLaporan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const OwnerDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const _AppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _NavSection(
                      title: 'Toko',
                      onTap: () => context.push(AppRoutes.ownerPengaturanToko),
                    ),
                    _NavSection(
                      title: 'Point of Sale',
                      onTap: () => context.push(AppRoutes.ownerPengaturanPos),
                    ),
                    _NavSection(
                      title: 'Pajak Toko',
                      onTap: () => context.push(AppRoutes.ownerPengaturanPajak),
                    ),
                    _PengaturanSection(
                      title: 'Mata Uang Penjualan',
                      children: [
                        _NavTile(
                          label: 'Mata Uang',
                          value: 'Rupiah (IDR)',
                          onTap: () {},
                        ),
                        _NavTile(
                          label: 'Format Angka',
                          value: '1.000.000',
                          onTap: () {},
                        ),
                        _NavTile(
                          label: 'Simbol',
                          value: 'Rp',
                          onTap: () {},
                        ),
                      ],
                    ),
                    _PengaturanSection(
                      title: 'Ringkasan Shift',
                      children: [
                        _ToggleTile(
                          label: 'Tampilkan Ringkasan Otomatis',
                          value: _ringkasanOtomatis,
                          onChanged: (v) =>
                              setState(() => _ringkasanOtomatis = v),
                        ),
                        _ToggleTile(
                          label: 'Cetak Otomatis Saat Shift Ditutup',
                          value: _cetakOtomatis,
                          onChanged: (v) => setState(() => _cetakOtomatis = v),
                        ),
                      ],
                    ),
                    _PengaturanSection(
                      title: 'Layout Toko',
                      children: [
                        _NavTile(
                          label: 'Tema Warna',
                          value: 'Gold (Default)',
                          onTap: () {},
                        ),
                        _NavTile(
                          label: 'Pengaturan Meja',
                          onTap: () {},
                        ),
                        _NavTile(
                          label: 'Tampilan Menu',
                          value: 'Grid',
                          onTap: () {},
                        ),
                      ],
                    ),
                    _PengaturanSection(
                      title: 'Notifikasi',
                      children: [
                        _ToggleTile(
                          label: 'Pesanan Baru',
                          value: _notifikasiPesanan,
                          onChanged: (v) =>
                              setState(() => _notifikasiPesanan = v),
                        ),
                        _ToggleTile(
                          label: 'Stok Rendah',
                          value: _notifikasiStok,
                          onChanged: (v) =>
                              setState(() => _notifikasiStok = v),
                        ),
                        _ToggleTile(
                          label: 'Laporan Harian',
                          value: _notifikasiLaporan,
                          onChanged: (v) =>
                              setState(() => _notifikasiLaporan = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.shellBackground),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Material(
              color: AppColors.primary,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: const SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.menu_rounded,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Text(
              'Pengaturan',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expandable section ────────────────────────────────────────────────────────

class _PengaturanSection extends StatelessWidget {
  const _PengaturanSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x2,
          ),
          childrenPadding: EdgeInsets.zero,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          title: Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const _ChevronIcon(),
          children: [
            const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ChevronIcon extends StatelessWidget {
  const _ChevronIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: AppColors.onSurfaceVariant,
      size: 24,
    );
  }
}

// ── Nav section (top-level row that pushes a detail page) ────────────────────

class _NavSection extends StatelessWidget {
  const _NavSection({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x5,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav tile ──────────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    this.value,
    this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x4,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.x1),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x5,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryContainer,
            inactiveThumbColor: AppColors.onSurfaceVariant,
            inactiveTrackColor: AppColors.outlineVariant,
          ),
        ],
      ),
    );
  }
}
