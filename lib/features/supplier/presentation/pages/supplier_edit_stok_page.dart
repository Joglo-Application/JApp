import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/supplier_item.dart';
import '../providers/supplier_provider.dart';
import '../widgets/foto_source_picker.dart';

// ── Stub data (mirrors tambah page) ──────────────────────────────────────────

const _kKategori = ['Bahan Dasar', 'Bumbu', 'Cabe', 'Saos', 'Frozen Food'];
const _kSatuan = [
  'Butir',
  'Centimeter',
  'Gram',
  'Kilogram',
  'Liter',
  'Meter',
  'Miligram',
  'Mililiter',
  'Porsi',
];

// ── Field keys ────────────────────────────────────────────────────────────────

const _kNama = 'nama';
const _kKategori_ = 'kategori';
const _kSatuan_ = 'satuan';
const _kKonverter = 'konverter';
const _kQtyStok = 'qtyStok';
const _kQtyTahan = 'qtyTahan';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _parseSatuan(String unitProduk) {
  final idx = unitProduk.indexOf(' (');
  return idx >= 0 ? unitProduk.substring(0, idx) : unitProduk;
}

String _parseKonverter(String unitProduk) {
  final match = RegExp(r'\((\d+)\)').firstMatch(unitProduk);
  return match?.group(1) ?? '0';
}

// ── Page ─────────────────────────────────────────────────────────────────────

class SupplierEditStokPage extends StatefulWidget {
  const SupplierEditStokPage({
    super.key,
    required this.item,
    required this.provider,
  });

  final SupplierItem item;
  final SupplierProvider provider;

  @override
  State<SupplierEditStokPage> createState() => _SupplierEditStokPageState();
}

class _SupplierEditStokPageState extends State<SupplierEditStokPage> {
  late final TextEditingController _namaCtrl;
  late final TextEditingController _konverterCtrl;
  late final TextEditingController _qtyStokCtrl;
  late final TextEditingController _qtyTahanCtrl;

  late String? _fotoUrl; // URL foto lama dari server (bila ada)
  XFile? _fotoFile; // foto baru yang dipilih (bila ada)
  Uint8List? _fotoBytes; // bytes foto baru, untuk pratinjau + unggah
  late String? _selectedKategori;
  late String? _selectedSatuan;

  final _unlocked = <String>{};

  bool _isUnlocked(String field) => _unlocked.contains(field);
  void _unlock(String field) => setState(() => _unlocked.add(field));

  bool _hasAnyChange() {
    return _namaCtrl.text.trim() != widget.item.nama ||
        _selectedKategori != widget.item.kategori ||
        _selectedSatuan != _parseSatuan(widget.item.unitProduk) ||
        _konverterCtrl.text.trim() != _parseKonverter(widget.item.unitProduk) ||
        _qtyStokCtrl.text.trim() != '${widget.item.qtyStok}' ||
        _qtyTahanCtrl.text.trim() != '${widget.item.qtyTahan}' ||
        _fotoBytes != null; // foto baru dipilih
  }

  @override
  void initState() {
    super.initState();
    _fotoUrl = widget.item.imageUrl;
    _selectedKategori = widget.item.kategori;
    _selectedSatuan = _parseSatuan(widget.item.unitProduk);
    _namaCtrl = TextEditingController(text: widget.item.nama);
    _konverterCtrl = TextEditingController(
      text: _parseKonverter(widget.item.unitProduk),
    );
    _qtyStokCtrl = TextEditingController(text: '${widget.item.qtyStok}');
    _qtyTahanCtrl = TextEditingController(text: '${widget.item.qtyTahan}');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _konverterCtrl.dispose();
    _qtyStokCtrl.dispose();
    _qtyTahanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDirty = _hasAnyChange();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Kiri: blok unggah foto ──
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    child: SizedBox(
                      width: 480,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(label: 'Foto', required: true),
                          const SizedBox(height: AppSpacing.x3),
                          _FotoInput(
                            remoteUrl: _fotoUrl,
                            pickedBytes: _fotoBytes,
                            onPick: _pickImage,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Kanan: form ──
                  Expanded(
                    child: ListView(
                      children: [
                        // Nama
                        _Section(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LabelRow(
                                label: 'Nama',
                                required: true,
                                locked: !_isUnlocked(_kNama),
                                onUnlock: () => _unlock(_kNama),
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              _EditableTextInput(
                                controller: _namaCtrl,
                                hint: 'Nama',
                                readOnly: !_isUnlocked(_kNama),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),

                        // Kategori
                        _Section(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LabelRow(
                                label: 'Kategori',
                                required: true,
                                locked: !_isUnlocked(_kKategori_),
                                onUnlock: () => _unlock(_kKategori_),
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              _EditableDropdown(
                                value: _selectedKategori,
                                items: _kKategori,
                                enabled: _isUnlocked(_kKategori_),
                                pickerStyle: _PickerStyle.gold,
                                onChanged: (v) =>
                                    setState(() => _selectedKategori = v),
                              ),
                            ],
                          ),
                        ),

                        // Satuan
                        _Section(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LabelRow(
                                label: 'Satuan',
                                required: true,
                                locked: !_isUnlocked(_kSatuan_),
                                onUnlock: () => _unlock(_kSatuan_),
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              _EditableDropdown(
                                value: _selectedSatuan,
                                items: _kSatuan,
                                enabled: _isUnlocked(_kSatuan_),
                                pickerStyle: _PickerStyle.white,
                                onChanged: (v) =>
                                    setState(() => _selectedSatuan = v),
                              ),
                            ],
                          ),
                        ),

                        // Konverter Satuan
                        _Section(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LabelRow(
                                label: 'Konverter Satuan',
                                required: false,
                                locked: !_isUnlocked(_kKonverter),
                                onUnlock: () => _unlock(_kKonverter),
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              _EditableNumberInput(
                                controller: _konverterCtrl,
                                readOnly: !_isUnlocked(_kKonverter),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),

                        // Qty Stok + Qty Tahan
                        _Section(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _LabelRow(
                                      label: 'Qty Stok',
                                      required: true,
                                      locked: !_isUnlocked(_kQtyStok),
                                      onUnlock: () => _unlock(_kQtyStok),
                                    ),
                                    const SizedBox(height: AppSpacing.x2),
                                    _EditableNumberInput(
                                      controller: _qtyStokCtrl,
                                      readOnly: !_isUnlocked(_kQtyStok),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.x4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _LabelRow(
                                      label: 'Qty Tahan',
                                      required: false,
                                      locked: !_isUnlocked(_kQtyTahan),
                                      onUnlock: () => _unlock(_kQtyTahan),
                                    ),
                                    const SizedBox(height: AppSpacing.x2),
                                    _EditableNumberInput(
                                      controller: _qtyTahanCtrl,
                                      readOnly: !_isUnlocked(_kQtyTahan),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const _SectionDivider(),
            SafeArea(
              top: false,
              child: _BottomButtons(
                canSave: isDirty,
                onHapus: _hapus,
                onSimpan: isDirty ? _simpan : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Edit Stok',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close_rounded,
              size: 22,
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    // Pilih sumber (kamera/galeri) + persetujuan kamera lewat helper bersama.
    final file = await pickFotoFromSource(context);
    if (file == null) return;
    // Dibaca sebagai bytes supaya pratinjau bekerja di web dan bytes yang sama
    // dipakai ulang saat mengunggah pada _simpan.
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _fotoFile = file;
      _fotoBytes = bytes;
    });
  }

  void _hapus() {
    showDialog<bool>(
      context: context,
      builder: (_) => const _HapusConfirmDialog(),
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final ok = await widget.provider.deleteItem(widget.item.bahanId);
      if (!mounted) return;
      if (ok) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('${widget.item.nama} berhasil dihapus'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(widget.provider.error ?? 'Gagal menghapus'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _simpan() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Unggah foto baru dulu bila ada; URL hasilnya dikirim bersama perubahan.
    // Konverter masih tampilan FE — belum dikirim ke server.
    String? imageUrl;
    if (_fotoBytes != null && _fotoFile != null) {
      imageUrl = await widget.provider.uploadFoto(
        bytes: _fotoBytes!,
        namaFile: _fotoFile!.name,
      );
      if (imageUrl == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Foto gagal diunggah, coba lagi')),
        );
        return;
      }
    }

    final ok = await widget.provider.updateStok(
      widget.item.bahanId,
      namaBahan: _namaCtrl.text.trim(),
      satuan: _selectedSatuan ?? _parseSatuan(widget.item.unitProduk),
      stok: int.tryParse(_qtyStokCtrl.text.trim()) ?? widget.item.qtyStok,
      stokMinimum:
          int.tryParse(_qtyTahanCtrl.text.trim()) ?? widget.item.qtyTahan,
      kategori: _selectedKategori ?? widget.item.kategori,
      imageUrl: imageUrl,
    );
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Berhasil mengubah Stok Gudang'),
          backgroundColor: AppColors.tertiary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(widget.provider.error ?? 'Gagal mengubah stok'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ── Label row with pencil button ──────────────────────────────────────────────

class _LabelRow extends StatelessWidget {
  const _LabelRow({
    required this.label,
    required this.required,
    required this.locked,
    required this.onUnlock,
  });

  final String label;
  final bool required;
  final bool locked;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FieldLabel(label: label, required: required),
        const Spacer(),
        if (locked)
          GestureDetector(
            onTap: onUnlock,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.xs,
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppColors.onPrimary,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Layout helpers ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(AppSpacing.x4), child: child);
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant);
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    if (!required) {
      return Text(
        label,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Foto input ────────────────────────────────────────────────────────────────

class _FotoInput extends StatelessWidget {
  const _FotoInput({
    required this.remoteUrl,
    required this.pickedBytes,
    required this.onPick,
  });
  final String? remoteUrl; // foto lama dari server
  final Uint8List? pickedBytes; // foto baru yang baru dipilih
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    // Foto baru menang atas foto lama. Keduanya web-safe: Image.memory untuk
    // bytes, Image.network (URL absolut) untuk foto server.
    final resolvedUrl = ApiConfig.resolveImageUrl(remoteUrl);
    final Widget? preview = pickedBytes != null
        ? Image.memory(pickedBytes!, fit: BoxFit.cover)
        : (resolvedUrl != null
              ? Image.network(resolvedUrl, fit: BoxFit.cover)
              : null);
    return GestureDetector(
      onTap: onPick,
      child: _DashedBorder(
        radius: 12,
        color: AppColors.primary,
        child: Container(
          width: double.infinity,
          height: 440,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.25),
            borderRadius: AppRadius.md,
          ),
          clipBehavior: Clip.antiAlias,
          child:
              preview ??
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  Text(
                    'Upload Foto',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    'JPEG, PNG, atau WebP · maks 5 MB',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

// ── Dashed border ─────────────────────────────────────────────────────────────

class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.child,
    required this.radius,
    required this.color,
  });
  final Widget child;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(radius: radius, color: color),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.radius, required this.color});
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 5.0;
    final source = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        dashed.addPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          Offset.zero,
        );
        distance = next + gap;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

// ── Editable text input ───────────────────────────────────────────────────────

class _EditableTextInput extends StatelessWidget {
  const _EditableTextInput({
    required this.controller,
    required this.hint,
    required this.readOnly,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: readOnly,
    onChanged: onChanged,
    style: AppTypography.textTheme.bodyMedium,
    decoration: _fieldDecoration(hint, readOnly),
  );
}

// ── Editable number input ─────────────────────────────────────────────────────

class _EditableNumberInput extends StatelessWidget {
  const _EditableNumberInput({
    required this.controller,
    required this.readOnly,
    this.onChanged,
  });
  final TextEditingController controller;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    onChanged: onChanged,
    style: AppTypography.textTheme.bodyMedium,
    decoration: _fieldDecoration('0', readOnly),
  );
}

// ── Editable dropdown ─────────────────────────────────────────────────────────

enum _PickerStyle { gold, white }

class _EditableDropdown extends StatelessWidget {
  const _EditableDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.pickerStyle,
    required this.enabled,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final _PickerStyle pickerStyle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => _showPicker(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? AppColors.outline : AppColors.outlineVariant,
          ),
          borderRadius: AppRadius.xs,
          color: enabled ? null : AppColors.surface,
        ),
        child: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: enabled
                  ? (value != null
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant)
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Text(
                value ?? 'Pilih',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: enabled
                      ? (value != null
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant)
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final future = pickerStyle == _PickerStyle.gold
        ? showDialog<String>(
            context: context,
            builder: (_) =>
                _GoldPickerDialog(items: items, selectedValue: value),
          )
        : showDialog<String>(
            context: context,
            builder: (_) =>
                _WhitePickerDialog(items: items, selectedValue: value),
          );
    future.then((result) {
      if (result != null) onChanged(result);
    });
  }
}

// ── Gold picker ───────────────────────────────────────────────────────────────

class _GoldPickerDialog extends StatelessWidget {
  const _GoldPickerDialog({required this.items, this.selectedValue});
  final List<String> items;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primary,
      shape: AppRadius.toShape(AppRadius.lg),
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x4,
                AppSpacing.x2,
                AppSpacing.x4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.onPrimary,
                    ),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.55,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.x4),
                children: items
                    .map(
                      (item) => _GoldPickerItem(
                        label: item,
                        isSelected: item == selectedValue,
                        onTap: () => Navigator.of(context).pop(item),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldPickerItem extends StatelessWidget {
  const _GoldPickerItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? AppColors.onPrimary.withValues(alpha: 0.15)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.onPrimary,
              ),
          ],
        ),
      ),
    );
  }
}

// ── White picker ──────────────────────────────────────────────────────────────

class _WhitePickerDialog extends StatelessWidget {
  const _WhitePickerDialog({required this.items, this.selectedValue});
  final List<String> items;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: AppRadius.toShape(AppRadius.lg),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x4,
                AppSpacing.x2,
                AppSpacing.x4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.60,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x4,
                  0,
                  AppSpacing.x4,
                  AppSpacing.x4,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.x2),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _WhitePickerItem(
                    label: item,
                    isSelected: item == selectedValue,
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhitePickerItem extends StatelessWidget {
  const _WhitePickerItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field decoration ──────────────────────────────────────────────────────────

InputDecoration _fieldDecoration(String hint, bool readOnly) {
  final borderColor = readOnly ? AppColors.outlineVariant : AppColors.outline;
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.x3,
      vertical: AppSpacing.x3,
    ),
    border: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: readOnly
          ? BorderSide(color: borderColor)
          : const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}

// ── Bottom buttons ────────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.canSave,
    required this.onHapus,
    required this.onSimpan,
  });
  final bool canSave;
  final VoidCallback onHapus;
  final VoidCallback? onSimpan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Btn(
            label: 'Hapus',
            color: AppColors.error,
            textColor: Colors.white,
            onPressed: onHapus,
          ),
        ),
        Expanded(
          child: _Btn(
            label: 'Simpan',
            color: canSave ? AppColors.tertiary : AppColors.outline,
            textColor: canSave
                ? AppColors.onTertiary
                : AppColors.onSurfaceVariant,
            onPressed: onSimpan,
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
    required this.onPressed,
  });
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: color,
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

// ── Hapus confirmation dialog ─────────────────────────────────────────────────

class _HapusConfirmDialog extends StatelessWidget {
  const _HapusConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: AppRadius.toShape(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                color: AppColors.onPrimary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Apakah kamu yakin?',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x5),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Tidak',
                    color: AppColors.outline,
                    textColor: AppColors.onSurface,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.x3),
                Expanded(
                  child: _DialogBtn(
                    label: 'Ya',
                    color: AppColors.primary,
                    textColor: AppColors.onPrimary,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogBtn extends StatelessWidget {
  const _DialogBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.sm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
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
