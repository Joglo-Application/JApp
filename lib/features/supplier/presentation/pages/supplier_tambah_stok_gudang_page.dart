import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/supplier_item.dart';
import '../providers/supplier_provider.dart';

// ── Main page ─────────────────────────────────────────────────────────────────

class SupplierTambahStokGudangPage extends StatefulWidget {
  const SupplierTambahStokGudangPage({super.key, required this.provider});

  final SupplierProvider provider;

  @override
  State<SupplierTambahStokGudangPage> createState() =>
      _SupplierTambahStokGudangPageState();
}

class _SupplierTambahStokGudangPageState
    extends State<SupplierTambahStokGudangPage> {
  SupplierItem? _selectedProduk;
  final _qtyCtrl = TextEditingController();

  bool get _isValid =>
      _selectedProduk != null && _qtyCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: AppColors.outlineVariant),
            Expanded(
              child: ListView(
                children: [
                  // Pilih Produk section
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Produk',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x3),
                        _PilihProdukButton(onTap: _navigateToPilihProduk),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.outlineVariant),

                  // Selected product row
                  if (_selectedProduk != null)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.x4),
                      child: _SelectedProdukRow(
                        produk: _selectedProduk!,
                        qtyCtrl: _qtyCtrl,
                        onQtyChanged: (_) => setState(() {}),
                        onRemove: () => setState(() {
                          _selectedProduk = null;
                          _qtyCtrl.clear();
                        }),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.outlineVariant),
            _BottomButtons(
              canSave: _isValid,
              onCancel: () => Navigator.of(context).pop(),
              onSimpan: _simpan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Tambah Stok Gudang',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close_rounded, size: 22),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPilihProduk() async {
    final result = await Navigator.of(context).push<SupplierItem>(
      MaterialPageRoute<SupplierItem>(
        fullscreenDialog: false,
        builder: (_) => _PilihProdukPage(
          items: widget.provider.items,
          selectedId: _selectedProduk?.id,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _selectedProduk = result);
    }
  }

  Future<void> _simpan() async {
    if (!_isValid) return;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await widget.provider.tambahStok(_selectedProduk!.bahanId, qty);
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Berhasil menambahkan Stok Gudang'),
          backgroundColor: AppColors.tertiary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(widget.provider.error ?? 'Gagal menambah stok'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ── Pilih Produk gold button ──────────────────────────────────────────────────

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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 20),
              const SizedBox(width: AppSpacing.x2),
              Text(
                'Pilih Produk',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Selected product row ──────────────────────────────────────────────────────

class _SelectedProdukRow extends StatelessWidget {
  const _SelectedProdukRow({
    required this.produk,
    required this.qtyCtrl,
    required this.onQtyChanged,
    required this.onRemove,
  });

  final SupplierItem produk;
  final TextEditingController qtyCtrl;
  final ValueChanged<String> onQtyChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Nama Produk',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                'Qty Produk',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 48 + AppSpacing.x2),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                enabled: false,
                controller: TextEditingController(text: produk.nama),
                style: AppTypography.textTheme.bodyMedium,
                decoration: _fieldDecoration(''),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onQtyChanged,
                style: AppTypography.textTheme.bodyMedium,
                decoration: _fieldDecoration('0'),
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            _TrashButton(onTap: onRemove),
          ],
        ),
      ],
    );
  }
}

class _TrashButton extends StatelessWidget {
  const _TrashButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: AppRadius.xs,
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 22,
        ),
      ),
    );
  }
}

// ── Product picker sub-page ───────────────────────────────────────────────────

class _PilihProdukPage extends StatefulWidget {
  const _PilihProdukPage({required this.items, this.selectedId});
  final List<SupplierItem> items;
  final String? selectedId;

  @override
  State<_PilihProdukPage> createState() => _PilihProdukPageState();
}

class _PilihProdukPageState extends State<_PilihProdukPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<SupplierItem> get _filtered => widget.items
      .where((p) => p.nama.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
                vertical: AppSpacing.x3,
              ),
              child: _SearchField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const Divider(height: 1, color: AppColors.outlineVariant),
            Expanded(
              child: ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  color: AppColors.outlineVariant,
                ),
                itemBuilder: (context, index) {
                  final produk = _filtered[index];
                  final isSelected = produk.id == widget.selectedId;
                  return _ProdukTile(
                    produk: produk,
                    isSelected: isSelected,
                    onTap: () => Navigator.of(context).pop(produk),
                  );
                },
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
        children: [
          const Spacer(),
          Text(
            'Tambah Stok Gudang',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close_rounded, size: 22),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.outlineVariant,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.x3),
            child: Icon(Icons.search_rounded,
                color: AppColors.onSurfaceVariant, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Cari',
                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.x3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProdukTile extends StatelessWidget {
  const _ProdukTile({
    required this.produk,
    required this.isSelected,
    required this.onTap,
  });
  final SupplierItem produk;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: isSelected
            ? AppColors.primaryContainer.withValues(alpha: 0.3)
            : AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Text(
            produk.nama,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom buttons ────────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.canSave,
    required this.onCancel,
    required this.onSimpan,
  });
  final bool canSave;
  final VoidCallback onCancel;
  final VoidCallback onSimpan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Btn(
            label: 'Cancel',
            color: AppColors.surface,
            textColor: AppColors.onSurface,
            bordered: true,
            onPressed: onCancel,
          ),
        ),
        Expanded(
          child: _Btn(
            label: 'Simpan',
            color: canSave ? AppColors.tertiary : AppColors.outline,
            textColor: canSave
                ? AppColors.onTertiary
                : AppColors.onSurfaceVariant,
            onPressed: canSave ? onSimpan : null,
          ),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.color,
    required this.textColor,
    this.bordered = false,
    required this.onPressed,
  });
  final String label;
  final Color color;
  final Color textColor;
  final bool bordered;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: color,
        shape: bordered
            ? RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.outline),
              )
            : null,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Field decoration ──────────────────────────────────────────────────────────

InputDecoration _fieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
    isDense: true,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.x3,
      vertical: AppSpacing.x3,
    ),
    border: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}
