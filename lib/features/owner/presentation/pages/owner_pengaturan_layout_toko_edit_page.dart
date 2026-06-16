import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// One floor/area entry in "Denah Restoran" — a name plus its list of tables.
class LayoutTokoData {
  const LayoutTokoData({required this.nama, required this.meja});

  final String nama;
  final List<String> meja;
}

/// What [OwnerPengaturanLayoutTokoEditPage] hands back via `context.pop`.
class LayoutTokoEditResult {
  const LayoutTokoEditResult.saved(this.data) : deleted = false;

  const LayoutTokoEditResult.deleted()
      : data = null,
        deleted = true;

  final LayoutTokoData? data;
  final bool deleted;
}

/// Add/edit form for a single floor layout — name field, a "Tambah Meja"
/// list with a confirmation dialog per entry, and a destructive
/// "Hapus Layout" action. Pass [initialData] to edit an existing layout;
/// omit it to add a new one.
class OwnerPengaturanLayoutTokoEditPage extends StatefulWidget {
  const OwnerPengaturanLayoutTokoEditPage({super.key, this.initialData});

  final LayoutTokoData? initialData;

  @override
  State<OwnerPengaturanLayoutTokoEditPage> createState() =>
      _OwnerPengaturanLayoutTokoEditPageState();
}

class _OwnerPengaturanLayoutTokoEditPageState
    extends State<OwnerPengaturanLayoutTokoEditPage> {
  late final _namaController = TextEditingController(
    text: widget.initialData?.nama ?? '',
  );
  late final List<String> _meja = List.of(widget.initialData?.meja ?? []);

  bool get _isEditing => widget.initialData != null;

  bool get _canSave =>
      _namaController.text.trim().isNotEmpty && _meja.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _namaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: _isEditing ? 'Edit' : 'Tambah Layout',
              canSave: _canSave,
              onSave: _onSimpan,
              onClose: () => context.pop(),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNamaLayout(),
                    _buildTambahMeja(),
                  ],
                ),
              ),
            ),
            _buildHapusLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildNamaLayout() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama Layout',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          TextField(
            controller: _namaController,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
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
          ),
        ],
      ),
    );
  }

  Widget _buildTambahMeja() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Tambah Meja',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _PillButton(label: 'Tambah', onTap: _onTambahMeja),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),
          for (var i = 0; i < _meja.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.x3),
            _MejaRow(
              label: _meja[i],
              onDelete: () => _onHapusMeja(i),
            ),
          ],
          const SizedBox(height: AppSpacing.x4),
        ],
      ),
    );
  }

  Widget _buildHapusLayout() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: AppColors.error,
          borderRadius: AppRadius.sm,
          child: InkWell(
            onTap: _onHapusLayout,
            borderRadius: AppRadius.sm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
              child: Text(
                'Hapus Layout',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSimpan() {
    if (!_canSave) return;
    context.pop(
      LayoutTokoEditResult.saved(
        LayoutTokoData(nama: _namaController.text.trim(), meja: _meja),
      ),
    );
  }

  Future<void> _onTambahMeja() async {
    final nama = await showDialog<String>(
      context: context,
      builder: (_) => const _TambahMejaDialog(),
    );
    if (nama == null || nama.trim().isEmpty || !mounted) return;
    setState(() => _meja.add(nama.trim()));
  }

  void _onHapusMeja(int index) {
    setState(() => _meja.removeAt(index));
  }

  Future<void> _onHapusLayout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Hapus Layout',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Yakin ingin menghapus layout ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'BATAL',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'HAPUS',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.pop(const LayoutTokoEditResult.deleted());
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.canSave,
    required this.onSave,
    required this.onClose,
  });

  final String title;
  final bool canSave;
  final VoidCallback onSave;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          FilledButton(
            onPressed: canSave ? onSave : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              disabledBackgroundColor: AppColors.outlineVariant,
              foregroundColor: AppColors.onTertiary,
              disabledForegroundColor: AppColors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x6,
                vertical: AppSpacing.x3,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Simpan',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: canSave ? AppColors.onTertiary : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          GestureDetector(
            onTap: onClose,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.onSurface,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pill button ──────────────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
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
                label,
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

// ── Meja row ─────────────────────────────────────────────────────────────────

class _MejaRow extends StatelessWidget {
  const _MejaRow({required this.label, required this.onDelete});

  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tambah meja dialog ────────────────────────────────────────────────────────

class _TambahMejaDialog extends StatefulWidget {
  const _TambahMejaDialog();

  @override
  State<_TambahMejaDialog> createState() => _TambahMejaDialogState();
}

class _TambahMejaDialogState extends State<_TambahMejaDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Masukkan Nama Meja',
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface,
        ),
        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.outline),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'BATAL',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(
            'KONFIRMASI',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
