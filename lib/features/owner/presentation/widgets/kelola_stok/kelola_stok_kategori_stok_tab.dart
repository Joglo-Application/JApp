import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../domain/entities/kategori_stok.dart';
import '../../providers/kelola_stok_provider.dart';

class KelolaStokKategoriStokTab extends StatelessWidget {
  const KelolaStokKategoriStokTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const Divider(height: 1),
        Expanded(child: _buildList(context)),
      ],
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
          Text(
            'Kategori Stok',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _TambahButton(
            onPressed: () => _openDialog(context, null),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final list = context.select<KelolaStokProvider, List<KategoriStok>>(
      (p) => p.kategoriStokList,
    );
    final provider = context.read<KelolaStokProvider>();

    return ReorderableListView.builder(
      itemCount: list.length,
      onReorder: provider.reorderKategoriStok,
      buildDefaultDragHandles: false,
      itemBuilder: (ctx, i) => _KategoriRow(
        key: ValueKey(list[i].id),
        index: i,
        kategori: list[i],
        onEdit: () => _openDialog(ctx, list[i]),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context, KategoriStok? existing) async {
    final provider = context.read<KelolaStokProvider>();
    await KategoriStokDialog.show(context, existing: existing, provider: provider);
  }
}

class _KategoriRow extends StatelessWidget {
  const _KategoriRow({
    super.key,
    required this.index,
    required this.kategori,
    required this.onEdit,
  });

  final int index;
  final KategoriStok kategori;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Icon(
                  Icons.drag_handle_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Text(
                  kategori.nama,
                  style: AppTypography.textTheme.bodyMedium,
                ),
              ),
              Text(
                '${kategori.produkCount} Produk',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 20),
                color: AppColors.onSurfaceVariant,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _TambahButton extends StatelessWidget {
  const _TambahButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Tambah'),
      ),
    );
  }
}

class KategoriStokDialog extends StatefulWidget {
  const KategoriStokDialog({
    super.key,
    this.existing,
    required this.provider,
  });

  final KategoriStok? existing;
  final KelolaStokProvider provider;

  static Future<void> show(
    BuildContext context, {
    KategoriStok? existing,
    required KelolaStokProvider provider,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => KategoriStokDialog(existing: existing, provider: provider),
    );
  }

  @override
  State<KategoriStokDialog> createState() => _KategoriStokDialogState();
}

class _KategoriStokDialogState extends State<KategoriStokDialog> {
  late final TextEditingController _namaCtrl;
  String? _fotoPath;
  bool _canSave = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.existing?.nama ?? '');
    _fotoPath = widget.existing?.fotoPath;
    _canSave = _namaCtrl.text.trim().isNotEmpty;
    _namaCtrl.addListener(() {
      final valid = _namaCtrl.text.trim().isNotEmpty;
      if (valid != _canSave) setState(() => _canSave = valid);
    });
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: AppRadius.toShape(AppRadius.lg),
      child: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            _buildContent(),
            const Divider(height: 1),
            _buildFooter(),
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
            'Tambahkan Kategori',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama Kategori',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          TextFormField(
            controller: _namaCtrl,
            style: AppTypography.textTheme.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
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
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3,
                vertical: AppSpacing.x3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x4),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.x4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Foto Kategori',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _FotoKategoriPicker(
                fotoPath: _fotoPath,
                onPicked: (path) => setState(() => _fotoPath = path),
              ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: AppSpacing.x4),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.x4),
            _HapusButton(onPressed: _onHapus),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x6,
        vertical: AppSpacing.x4,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppOutlinedButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              width: double.infinity,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(child: _SaveButton(enabled: _canSave, onPressed: _onSave)),
        ],
      ),
    );
  }

  void _onSave() {
    final nama = _namaCtrl.text.trim();
    if (_isEditing) {
      final updated = widget.existing!
        ..nama = nama
        ..fotoPath = _fotoPath;
      widget.provider.updateKategoriStok(updated);
    } else {
      widget.provider.addKategoriStok(
        KategoriStok(
          id: widget.provider.generateKategoriId(),
          nama: nama,
          fotoPath: _fotoPath,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  void _onHapus() {
    widget.provider.removeKategoriStok(widget.existing!.id);
    Navigator.of(context).pop();
  }
}

class _FotoKategoriPicker extends StatelessWidget {
  const _FotoKategoriPicker({required this.fotoPath, required this.onPicked});

  final String? fotoPath;
  final ValueChanged<String?> onPicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerSheet(context),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.sm,
          border: Border.all(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: fotoPath != null
            ? Image.file(File(fotoPath!), fit: BoxFit.cover)
            : const Icon(
                Icons.image_rounded,
                color: AppColors.onSurfaceVariant,
                size: 32,
              ),
      ),
    );
  }

  Future<void> _showPickerSheet(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    final file = await ImagePicker().pickImage(source: source);
    if (file != null) onPicked(file.path);
  }
}

class _HapusButton extends StatelessWidget {
  const _HapusButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
        child: const Text('Hapus Kategori'),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.tertiary,
          foregroundColor: AppColors.onTertiary,
          disabledBackgroundColor: AppColors.tertiary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
        child: const Text('Save'),
      ),
    );
  }
}
