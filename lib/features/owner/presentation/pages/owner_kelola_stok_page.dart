import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/kelola_stok_provider.dart';
import '../widgets/kelola_stok/kelola_stok_app_bar.dart';
import '../widgets/kelola_stok/kelola_stok_kategori_stok_tab.dart';
import '../widgets/kelola_stok/kelola_stok_produksi_stok_tab.dart';
import '../widgets/kelola_stok/kelola_stok_stok_keluar_tab.dart';
import '../widgets/kelola_stok/kelola_stok_stok_masuk_tab.dart';
import '../widgets/kelola_stok/kelola_stok_stok_opname_tab.dart';
import '../widgets/navigation/owner_drawer.dart';

class OwnerKelolaStokPage extends StatelessWidget {
  const OwnerKelolaStokPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KelolaStokProvider(),
      child: _KelolaStokView(drawer: drawer),
    );
  }
}

class _KelolaStokView extends StatefulWidget {
  const _KelolaStokView({this.drawer});

  final Widget? drawer;

  @override
  State<_KelolaStokView> createState() => _KelolaStokViewState();
}

class _KelolaStokViewState extends State<_KelolaStokView> {
  int _tabIndex = 0;

  static const _tabs = [
    'Stok Masuk',
    'Stok Keluar',
    'Produksi Stok',
    'Stok Opname',
    'Kategori Stok',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: widget.drawer ?? const OwnerDrawer(activePage: OwnerDrawerPage.kelolaStok),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KelolaStokAppBar(),
          _KelolaStokTabBar(
            tabs: _tabs,
            selectedIndex: _tabIndex,
            onTabSelected: (i) => setState(() => _tabIndex = i),
          ),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_tabIndex) {
      0 => const KelolaStokStokMasukTab(),
      1 => const KelolaStokStokKeluarTab(),
      2 => const KelolaStokProduksiStokTab(),
      3 => const KelolaStokStokOpnameTab(),
      4 => const KelolaStokKategoriStokTab(),
      _ => const _PlaceholderTab(),
    };
  }
}

class _KelolaStokTabBar extends StatelessWidget {
  const _KelolaStokTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onTabSelected(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x2,
                  vertical: AppSpacing.x2,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x3,
                    vertical: AppSpacing.x2,
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
