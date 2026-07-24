import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/supplier_provider.dart';
import '../widgets/foto_source_picker.dart';

// ── Stub data ─────────────────────────────────────────────────────────────────

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

// ── Page ─────────────────────────────────────────────────────────────────────

class SupplierTambahStokBaruPage extends StatefulWidget {
  const SupplierTambahStokBaruPage({super.key, required this.provider});

  final SupplierProvider provider;

  @override
  State<SupplierTambahStokBaruPage> createState() =>
      _SupplierTambahStokBaruPageState();
}

class _SupplierTambahStokBaruPageState
    extends State<SupplierTambahStokBaruPage> {
  final _namaCtrl = TextEditingController();
  final _konverterCtrl = TextEditingController(text: '0');
  final _qtyStokCtrl = TextEditingController();
  final _qtyTahanCtrl = TextEditingController();

  XFile? _fotoFile;
  Uint8List? _fotoBytes;
  String? _selectedKategori;
  String? _selectedSatuan;

  // Foto opsional — tidak diwajibkan agar user tak selalu harus mengunggah.
  bool get _isValid =>
      _namaCtrl.text.trim().isNotEmpty &&
      _selectedKategori != null &&
      _selectedSatuan != null &&
      _qtyStokCtrl.text.trim().isNotEmpty;

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
                          const _FieldLabel(label: 'Foto', required: false),
                          const SizedBox(height: AppSpacing.x3),
                          _FotoInput(fotoBytes: _fotoBytes, onPick: _pickImage),
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
                              const _FieldLabel(label: 'Nama', required: true),
                              const SizedBox(height: AppSpacing.x2),
                              _TextInput(
                                controller: _namaCtrl,
                                hint: 'Nama',
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
                              const _FieldLabel(
                                label: 'Kategori',
                                required: true,
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              _DropdownInput(
                                value: _selectedKategori,
                                items: _kKategori,
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
                              const _FieldLabel(
                                label: 'Satuan',
                                required: true,
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              _DropdownInput(
                                value: _selectedSatuan,
                                items: _kSatuan,
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
                              const _FieldLabel(
                                label: 'Konverter Satuan',
                                required: false,
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              _NumberInput(controller: _konverterCtrl),
                            ],
                          ),
                        ),

                        // Qty Stok + Qty Tahan (visible after Satuan selected)
                        if (_selectedSatuan != null) ...[
                          _Section(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel(
                                        label: 'Qty Stok',
                                        required: true,
                                      ),
                                      const SizedBox(height: AppSpacing.x2),
                                      _NumberInput(
                                        controller: _qtyStokCtrl,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.x4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel(
                                        label: 'Qty Tahan',
                                        required: false,
                                      ),
                                      const SizedBox(height: AppSpacing.x2),
                                      _NumberInput(controller: _qtyTahanCtrl),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const _SectionDivider(),
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
            'Tambah Stok Baru',
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
    // Dibaca sebagai bytes supaya pratinjau bekerja di web (Image.file tidak
    // didukung di Flutter Web); bytes yang sama dipakai ulang saat mengunggah.
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _fotoFile = file;
      _fotoBytes = bytes;
    });
  }

  Future<void> _simpan() async {
    if (!_isValid) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // Foto diunggah lebih dulu; URL hasilnya yang disimpan bersama bahan.
    // Dibaca sebagai bytes, bukan path, supaya tetap bekerja di web.
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

    // Catatan: "konverter" masih tampilan FE — belum dikirim ke server.
    final ok = await widget.provider.createItem(
      namaBahan: _namaCtrl.text.trim(),
      satuan: _selectedSatuan!,
      stok: int.tryParse(_qtyStokCtrl.text.trim()) ?? 0,
      stokMinimum: int.tryParse(_qtyTahanCtrl.text.trim()) ?? 0,
      kategori: _selectedKategori,
      imageUrl: imageUrl,
    );
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Berhasil menambahkan ke Stok Gudang'),
          backgroundColor: AppColors.tertiary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(widget.provider.error ?? 'Gagal menambahkan stok'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

// ── Input widgets ─────────────────────────────────────────────────────────────

class _FotoInput extends StatelessWidget {
  const _FotoInput({required this.fotoBytes, required this.onPick});
  final Uint8List? fotoBytes;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
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
          // Image.memory bekerja di web maupun mobile (Image.file tidak di web).
          child: fotoBytes != null
              ? Image.memory(fotoBytes!, fit: BoxFit.cover)
              : Column(
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

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    style: AppTypography.textTheme.bodyMedium,
    decoration: _fieldDecoration(hint),
  );
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({required this.controller, this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    onChanged: onChanged,
    style: AppTypography.textTheme.bodyMedium,
    decoration: _fieldDecoration('0'),
  );
}

// ── Dropdown picker ───────────────────────────────────────────────────────────

enum _PickerStyle { gold, white }

class _DropdownInput extends StatelessWidget {
  const _DropdownInput({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.pickerStyle,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final _PickerStyle pickerStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: AppRadius.xs,
        ),
        child: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: value != null
                  ? AppColors.onSurface
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Text(
                value ?? 'Pilih',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: value != null
                      ? AppColors.onSurface
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

// ── Gold picker (Kategori style) ──────────────────────────────────────────────

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

// ── White picker (Satuan style) ───────────────────────────────────────────────

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

// ── Shared field decoration ───────────────────────────────────────────────────

InputDecoration _fieldDecoration(String hint) {
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
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.xs,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
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
