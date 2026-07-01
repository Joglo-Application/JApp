import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../owner/domain/entities/stok_gudang_item.dart';
import '../../domain/entities/inventori_item.dart';
import '../../domain/entities/menu_resep_input.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/update_menu_params.dart';
import '../widgets/inventori/inventori_form_widgets.dart';

/// Navigation payload for [AppRoutes.inventoriEditItem] (passed via
/// `GoRouterState.extra`, following the pattern used by `VoucherEditArgs`).
class InventoriEditItemArgs {
  const InventoriEditItemArgs({required this.item, this.menu});

  final InventoriItem item;

  /// Richer `GET /menus` record (harga, isActive) for [item], when available.
  final Product? menu;
}

/// Edit screen for an existing inventori/menu item.
///
/// Nama, Kategori, Harga jual toko and Royalty Point are locked by default
/// and unlock one at a time via their pencil button; the top-level Simpan
/// button is the only thing that actually persists changes (`PATCH
/// /menus/{id}`), matching the flow in the design handoff.
class InventoriEditItemPage extends StatefulWidget {
  const InventoriEditItemPage({super.key, required this.item, this.menu});

  final InventoriItem item;

  /// Richer `GET /menus` record (harga, isActive) for [item], when available.
  final Product? menu;

  @override
  State<InventoriEditItemPage> createState() => _InventoriEditItemPageState();
}

class _InventoriEditItemPageState extends State<InventoriEditItemPage> {
  late final _namaCtrl = TextEditingController(text: widget.item.nama);
  late final _hargaCtrl = TextEditingController(
    text: widget.menu != null ? widget.menu!.price.toInt().toString() : '',
  );
  late final _stokCtrl =
      TextEditingController(text: widget.item.qtyStok.toString());
  late final _peringatanStokCtrl =
      TextEditingController(text: widget.item.qtyTahan.toString());
  final _royaltyCtrl = TextEditingController();

  XFile? _pickedImage;
  late String? _kategori = widget.item.kategori;
  bool _produkKhusus = false;
  late bool _tampilkanDiPos = widget.menu?.isAvailable ?? true;
  DateTimeRange? _tanggalKhusus;
  final List<ResepEntry> _resepEntries = [];

  bool _editNama = false;
  bool _editKategori = false;
  bool _editHarga = false;
  bool _editRoyalty = false;

  final _picker = ImagePicker();

  static const _kategoriList = [
    'Makanan',
    'Minuman',
    'Snack',
    'Dessert',
    'Lainnya',
  ];

  bool get _canSave =>
      _namaCtrl.text.trim().isNotEmpty &&
      _kategori != null &&
      (int.tryParse(_hargaCtrl.text) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _namaCtrl.addListener(() => setState(() {}));
    _hargaCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _stokCtrl.dispose();
    _peringatanStokCtrl.dispose();
    _royaltyCtrl.dispose();
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
                    _buildTampilkanDiPosSection(),
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
          SimpanButton(enabled: _canSave, onTap: _onSimpan),
          const Spacer(),
          Text(
            'Edit Item',
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
        const SectionLabel('Foto'),
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
            child: _buildFotoPreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildFotoPreview() {
    if (_pickedImage != null) {
      return Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
    }
    if (widget.item.localImagePath != null) {
      return Image.file(File(widget.item.localImagePath!), fit: BoxFit.cover);
    }
    if (widget.item.imageUrl != null) {
      return Image.network(widget.item.imageUrl!, fit: BoxFit.cover);
    }
    return const Icon(
      Icons.add_photo_alternate_rounded,
      color: AppColors.onSurfaceVariant,
      size: 32,
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
        _EditableFieldHeader(
          label: 'Nama',
          isRequired: true,
          editing: _editNama,
          onToggle: () => setState(() => _editNama = !_editNama),
        ),
        const SizedBox(height: AppSpacing.x3),
        OutlinedInput(controller: _namaCtrl, enabled: _editNama),
      ],
    );
  }

  Widget _buildKategoriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EditableFieldHeader(
          label: 'Kategori',
          isRequired: true,
          editing: _editKategori,
          onToggle: () => setState(() => _editKategori = !_editKategori),
        ),
        const SizedBox(height: AppSpacing.x3),
        GestureDetector(
          onTap: _editKategori ? _pickKategori : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: _editKategori
                    ? AppColors.outline
                    : AppColors.outlineVariant,
              ),
              borderRadius: AppRadius.sm,
              color: _editKategori ? null : AppColors.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Icon(Icons.keyboard_arrow_down_rounded,
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
        _EditableFieldHeader(
          label: 'Harga jual toko',
          isRequired: true,
          editing: _editHarga,
          onToggle: () => setState(() => _editHarga = !_editHarga),
        ),
        const SizedBox(height: AppSpacing.x3),
        OutlinedInput(
          controller: _hargaCtrl,
          keyboardType: TextInputType.number,
          prefix: 'IDR  ',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: _editHarga,
        ),
      ],
    );
  }

  Widget _buildLacakInventoriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionLabel('Lacak inventori', isRequired: true),
            const Spacer(),
            Text(
              '* Tidak dapat di Edit',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x3),
        const SubLabel('Jumlah stok tersedia saat ini'),
        const SizedBox(height: AppSpacing.x2),
        OutlinedInput(
          controller: _stokCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: false,
        ),
        const SizedBox(height: AppSpacing.x3),
        const SubLabel('Peringatan sisa stok'),
        const SizedBox(height: AppSpacing.x2),
        OutlinedInput(
          controller: _peringatanStokCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: false,
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
            const SectionLabel('Resep Makanan', isRequired: true),
            const Spacer(),
            TambahSmallButton(onTap: _pilihBahan),
          ],
        ),
        if (_resepEntries.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.x3),
          for (int i = 0; i < _resepEntries.length; i++) ...[
            ResepEntryRow(
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
        _EditableFieldHeader(
          label: 'Royalty Point',
          isRequired: true,
          editing: _editRoyalty,
          onToggle: () => setState(() => _editRoyalty = !_editRoyalty),
        ),
        const SizedBox(height: AppSpacing.x3),
        OutlinedInput(
          controller: _royaltyCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: _editRoyalty,
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

  Widget _buildTampilkanDiPosSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tampilkan di POS',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.x1),
              Text(
                'Pesanan Secara tidak Langsung akan Tampil di POS',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _tampilkanDiPos,
          onChanged: (v) => setState(() => _tampilkanDiPos = v),
          activeTrackColor: AppColors.primary,
          activeThumbColor: AppColors.onPrimary,
        ),
      ],
    );
  }

  Future<void> _pilihBahan() async {
    final item = await context.push<StokGudangItem>(
      AppRoutes.inventoriPilihBahan,
    );
    if (item != null) setState(() => _resepEntries.add(ResepEntry(item)));
  }

  void _pickKategori() {
    showDialog<void>(
      context: context,
      builder: (_) => KategoriDialog(
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
    final resep = _resepEntries
        .map((e) => MenuResepInput(
              bahanId: e.item.bahanId,
              jumlahPakai: double.tryParse(e.jumlah.text.trim()) ?? 0,
            ))
        .where((r) => r.jumlahPakai > 0)
        .toList();

    final isKhusus = _produkKhusus && _tanggalKhusus != null;

    context.pop(
      UpdateMenuParams(
        id: widget.item.id,
        namaMenu: _namaCtrl.text.trim(),
        kategori: _kategori!,
        harga: int.tryParse(_hargaCtrl.text) ?? 0,
        isActive: _tampilkanDiPos,
        resep: resep,
        royaltyPoint: int.tryParse(_royaltyCtrl.text.trim()),
        isProdukKhusus: isKhusus,
        produkKhususMulai: isKhusus ? _apiDate(_tanggalKhusus!.start) : null,
        produkKhususSelesai: isKhusus ? _apiDate(_tanggalKhusus!.end) : null,
      ),
    );
  }

  /// `YYYY-MM-DD` for the API (the display helper uses dd/MM/yyyy).
  String _apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Section label with a pencil (locked) / Simpan (editing) toggle on the
/// right, matching the per-field inline-edit affordance in the design.
class _EditableFieldHeader extends StatelessWidget {
  const _EditableFieldHeader({
    required this.label,
    required this.editing,
    required this.onToggle,
    this.isRequired = false,
  });

  final String label;
  final bool editing;
  final bool isRequired;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SectionLabel(label, isRequired: isRequired),
        const Spacer(),
        editing
            ? SmallSimpanButton(onTap: onToggle)
            : EditPencilButton(onTap: onToggle),
      ],
    );
  }
}
