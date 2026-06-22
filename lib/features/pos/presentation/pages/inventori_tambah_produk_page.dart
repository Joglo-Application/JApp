import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../owner/domain/entities/stok_gudang_item.dart';
import '../../domain/entities/inventori_item.dart';

class InventoriTambahProdukPage extends StatefulWidget {
  const InventoriTambahProdukPage({super.key});

  @override
  State<InventoriTambahProdukPage> createState() =>
      _InventoriTambahProdukPageState();
}

class _ResepEntry {
  _ResepEntry(this.item) : jumlah = TextEditingController();
  final StokGudangItem item;
  final TextEditingController jumlah;

  void dispose() => jumlah.dispose();
}

class _InventoriTambahProdukPageState
    extends State<InventoriTambahProdukPage> {
  final _namaCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _stokCtrl = TextEditingController();
  final _peringatanStokCtrl = TextEditingController();
  final _royaltyCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  XFile? _pickedImage;
  String? _kategori;
  bool _produkKhusus = false;
  DateTimeRange? _tanggalKhusus;
  final List<_ResepEntry> _resepEntries = [];

  final _picker = ImagePicker();

  static const _kategoriList = [
    'Makanan',
    'Minuman',
    'Snack',
    'Dessert',
    'Lainnya',
  ];

  bool get _canSave => _namaCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _namaCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _stokCtrl.dispose();
    _peringatanStokCtrl.dispose();
    _royaltyCtrl.dispose();
    _catatanCtrl.dispose();
    for (final e in _resepEntries) {
      e.dispose();
    }
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
            const Divider(
                height: 1, thickness: 1, color: AppColors.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFotoSection(),
                    _sectionDivider(),
                    _buildNamaSection(),
                    _sectionDivider(),
                    _buildKategoriSection(),
                    _sectionDivider(),
                    _buildHargaSection(),
                    _sectionDivider(),
                    _buildLacakInventoriSection(),
                    _sectionDivider(),
                    _buildResepMakananSection(),
                    _sectionDivider(),
                    _buildRoyaltySection(),
                    _sectionDivider(),
                    _buildProdukKhususSection(),
                    _sectionDivider(),
                    _buildCatatanSection(),
                    const SizedBox(height: AppSpacing.x8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.x4),
        child: Divider(
            height: 1, thickness: 1, color: AppColors.outlineVariant),
      );

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          _SimpanButton(enabled: _canSave, onTap: _onSimpan),
          const Spacer(),
          Text(
            'Tambahkan Produk',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: AppRadius.full,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.x1),
              child: Icon(Icons.close_rounded,
                  size: 24, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Foto'),
        const SizedBox(height: AppSpacing.x3),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: AppRadius.sm,
              border: Border.all(color: AppColors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: _pickedImage != null
                ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                : const Icon(
                    Icons.add_photo_alternate_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 32,
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  Widget _buildNamaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Nama'),
        const SizedBox(height: AppSpacing.x3),
        _OutlinedInput(controller: _namaCtrl),
      ],
    );
  }

  Widget _buildKategoriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Kategori'),
        const SizedBox(height: AppSpacing.x3),
        GestureDetector(
          onTap: _pickKategori,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: AppRadius.sm,
            ),
            child: Row(
              children: [
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.onSurfaceVariant, size: 20),
                const SizedBox(width: AppSpacing.x2),
                Text(
                  _kategori ?? 'Pilih kategori',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: _kategori != null
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHargaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Harga jual toko'),
        const SizedBox(height: AppSpacing.x3),
        _OutlinedInput(
          controller: _hargaCtrl,
          keyboardType: TextInputType.number,
          prefix: 'IDR  ',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildLacakInventoriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Lacak inventori'),
        const SizedBox(height: AppSpacing.x3),
        _SubLabel('Jumlah stok tersedia saat ini'),
        const SizedBox(height: AppSpacing.x2),
        _OutlinedInput(
          controller: _stokCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: AppSpacing.x3),
        _SubLabel('Peringatan sisa stok'),
        const SizedBox(height: AppSpacing.x2),
        _OutlinedInput(
          controller: _peringatanStokCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildResepMakananSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionLabel('Resep Makanan'),
            const Spacer(),
            _TambahSmallButton(onTap: _pilihBahan),
          ],
        ),
        if (_resepEntries.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.x3),
          for (int i = 0; i < _resepEntries.length; i++) ...[
            _ResepEntryRow(
              entry: _resepEntries[i],
              onRemove: () => setState(() {
                _resepEntries[i].dispose();
                _resepEntries.removeAt(i);
              }),
            ),
            if (i < _resepEntries.length - 1)
              const SizedBox(height: AppSpacing.x3),
          ],
        ],
      ],
    );
  }

  Widget _buildRoyaltySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Royalty Point'),
        const SizedBox(height: AppSpacing.x3),
        _OutlinedInput(
          controller: _royaltyCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildProdukKhususSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Produk Khusus',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            Switch(
              value: _produkKhusus,
              onChanged: (v) => setState(() {
                _produkKhusus = v;
                if (!v) _tanggalKhusus = null;
              }),
              activeTrackColor: AppColors.primary,
              activeThumbColor: AppColors.onPrimary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        GestureDetector(
          onTap: _produkKhusus ? _pickTanggal : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: _produkKhusus
                    ? AppColors.outline
                    : AppColors.outlineVariant,
              ),
              borderRadius: AppRadius.sm,
              color: _produkKhusus ? null : AppColors.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: _produkKhusus
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.x2),
                Text(
                  _tanggalKhusus != null
                      ? '${_formatDate(_tanggalKhusus!.start)} - ${_formatDate(_tanggalKhusus!.end)}'
                      : 'Pilih Tanggal',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: _produkKhusus && _tanggalKhusus != null
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Catatan'),
        const SizedBox(height: AppSpacing.x3),
        _OutlinedInput(controller: _catatanCtrl, maxLines: 3),
      ],
    );
  }

  Future<void> _pilihBahan() async {
    final item = await context.push<StokGudangItem>(
      AppRoutes.inventoriPilihBahan,
    );
    if (item != null) setState(() => _resepEntries.add(_ResepEntry(item)));
  }

  void _pickKategori() {
    showDialog<void>(
      context: context,
      builder: (_) => _KategoriDialog(
        selected: _kategori,
        options: _kategoriList,
        onSelect: (k) => setState(() => _kategori = k),
      ),
    );
  }

  Future<void> _pickTanggal() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _tanggalKhusus,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggalKhusus = picked);
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  void _onSimpan() {
    if (!_canSave) return;
    final item = InventoriItem(
      id: const Uuid().v4(),
      nama: _namaCtrl.text.trim(),
      kategori: _kategori ?? '',
      qtyStok: int.tryParse(_stokCtrl.text) ?? 0,
      qtyTahan: int.tryParse(_peringatanStokCtrl.text) ?? 0,
      localImagePath: _pickedImage?.path,
    );
    context.pop(item);
  }
}

// ── Shared label widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

// ── Outlined text input ───────────────────────────────────────────────────────

class _OutlinedInput extends StatelessWidget {
  const _OutlinedInput({
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefix;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        prefixText: prefix,
        hintText: hint,
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
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

// ── Simpan button ─────────────────────────────────────────────────────────────

class _SimpanButton extends StatelessWidget {
  const _SimpanButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x6,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: enabled ? AppColors.tertiary : AppColors.outline,
          borderRadius: AppRadius.sm,
        ),
        child: Text(
          'Simpan',
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: enabled ? AppColors.onTertiary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Tambah small button ───────────────────────────────────────────────────────

class _TambahSmallButton extends StatelessWidget {
  const _TambahSmallButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded,
                size: 16, color: AppColors.onPrimary),
            const SizedBox(width: AppSpacing.x1),
            Text(
              'Tambah',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Resep entry row ───────────────────────────────────────────────────────────

class _ResepEntryRow extends StatelessWidget {
  const _ResepEntryRow({required this.entry, required this.onRemove});
  final _ResepEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final label =
        '${entry.item.nama} - ${entry.item.unitProduk} (${entry.item.qtyStok})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        _OutlinedInput(
          controller: entry.jumlah,
          hint: 'Jumlah',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}

// ── Kategori dialog ───────────────────────────────────────────────────────────

class _KategoriDialog extends StatelessWidget {
  const _KategoriDialog({
    required this.selected,
    required this.options,
    required this.onSelect,
  });
  final String? selected;
  final List<String> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: AppRadius.toShape(AppRadius.lg),
      backgroundColor: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              AppSpacing.x4,
              AppSpacing.x2,
              AppSpacing.x2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Pilih Kategori',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: AppColors.onSurface,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          ...options.map(
            (k) => InkWell(
              onTap: () {
                onSelect(k);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        k,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight:
                              k == selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (k == selected)
                      const Icon(Icons.check_rounded,
                          size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
        ],
      ),
    );
  }
}
