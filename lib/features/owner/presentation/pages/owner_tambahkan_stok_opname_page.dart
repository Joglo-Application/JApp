import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/stok_opname_entry.dart';
import '../providers/kelola_stok_provider.dart';
import '../widgets/kelola_stok/pilih_produk_dialog.dart';
import '../widgets/kelola_stok/tambah_produk_opname_dialog.dart';

class OwnerTambahkanStokOpnamePage extends StatefulWidget {
  const OwnerTambahkanStokOpnamePage({
    super.key,
    required this.provider,
    required this.initialTanggal,
    this.initialCatatan = '',
    this.existingEntry,
  });

  final KelolaStokProvider provider;
  final DateTime initialTanggal;
  final String initialCatatan;
  final StokOpnameEntry? existingEntry;

  @override
  State<OwnerTambahkanStokOpnamePage> createState() =>
      _OwnerTambahkanStokOpnamePageState();
}

class _OwnerTambahkanStokOpnamePageState
    extends State<OwnerTambahkanStokOpnamePage> {
  late final String _kode;
  late DateTime _tanggal;
  late String _catatan;
  final List<StokOpnameProdukItem> _produk = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingEntry;
    if (existing != null) {
      _kode = existing.kode;
      _tanggal = existing.tanggal;
      _catatan = existing.catatan ?? '';
      _produk.addAll(existing.produk.map(
        (p) => StokOpnameProdukItem(
          nama: p.nama,
          qtySystem: p.qtySystem,
          qtyAktual: p.qtyAktual,
        ),
      ));
    } else {
      _kode = widget.provider.generateKodeOpname();
      _tanggal = widget.initialTanggal;
      _catatan = widget.initialCatatan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleRow(),
            _buildInfoBanner(),
            _buildDocumentHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  _ProdukSection(
                    produk: _produk,
                    onTambah: _onTambahProduk,
                    onDelete: (item) => setState(() => _produk.remove(item)),
                    onQtyAktualChanged: (item, qty) =>
                        setState(() => item.qtyAktual = qty),
                  ),
                  const Divider(height: 1),
                  _DateRow(tanggal: _tanggal, onEdit: _pickDate),
                  const Divider(height: 1),
                  const _LabelValueRow(label: 'Created By', value: 'Dapur01'),
                  const Divider(height: 1),
                  _EditableSection(
                    label: 'Catatan',
                    value: _catatan.isEmpty ? 'Catatan' : _catatan,
                    isPlaceholder: _catatan.isEmpty,
                    onEdit: () => _editText(
                      'Catatan',
                      _catatan,
                      (v) => setState(() => _catatan = v),
                      multiline: true,
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
            const Divider(height: 1),
            _BottomButtons(
              onCancel: () => Navigator.of(context).pop(),
              onDraft: () => _save(StokOpnameStatus.draft),
              onPostNow: () => _save(StokOpnameStatus.posted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Tambahkan Stok Opname',
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

  Widget _buildInfoBanner() {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey[600]),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Text(
              'Pastikan data yang diposting sudah benar. Setelah diposting, data tidak boleh diubah.',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: AppColors.onPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _kode,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Draft',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: AppRadius.xs,
            ),
            child: const Icon(
              Icons.download_rounded,
              color: AppColors.onPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _editText(
    String label,
    String current,
    ValueChanged<String> onSave, {
    bool multiline = false,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _EditTextDialog(
        label: label,
        initial: current,
        multiline: multiline,
      ),
    );
    if (result != null) onSave(result);
  }

  Future<void> _onTambahProduk() async {
    // Opname boleh memuat bahan baku maupun produk jadi, jadi sumbernya
    // dipilih dulu — memakai dialog yang sama dengan alur Stok Masuk.
    final source = await PilihProdukDialog.show(context);
    if (source == null || !mounted) return;

    final alreadyAdded = _produk.map((p) => p.nama).toList();
    final items = await TambahProdukOpnamePage.push(
      context,
      source: source,
      alreadyAdded: alreadyAdded,
    );
    if (items == null || !mounted) return;
    setState(() => _produk.addAll(items));
  }

  Future<void> _save(StokOpnameStatus status) async {
    if (_produk.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu produk')),
      );
      return;
    }

    final entry = StokOpnameEntry(
      kode: _kode,
      tanggal: _tanggal,
      createdBy: 'Dapur01',
      catatan: _catatan.isEmpty ? null : _catatan,
      produk: List.of(_produk),
      status: status,
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (widget.existingEntry != null) {
      // Mengubah dokumen tersimpan belum didukung server.
      widget.provider.updateStokOpname(entry);
      navigator.pop();
      return;
    }

    final error = await widget.provider.addStokOpname(entry);
    if (!mounted) return;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    navigator.pop();
  }
}

// ── Produk section ────────────────────────────────────────────────────────────

class _ProdukSection extends StatelessWidget {
  const _ProdukSection({
    required this.produk,
    required this.onTambah,
    required this.onDelete,
    required this.onQtyAktualChanged,
  });

  final List<StokOpnameProdukItem> produk;
  final VoidCallback onTambah;
  final ValueChanged<StokOpnameProdukItem> onDelete;
  final void Function(StokOpnameProdukItem, int) onQtyAktualChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Text(
              'Produk (${produk.length})',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onTambah,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, size: 18),
                const SizedBox(width: AppSpacing.x1),
                Text(
                  'Tambah Produk',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...produk.map(
          (item) => Column(
            children: [
              const Divider(height: 1),
              _ProdukItemRow(
                item: item,
                onDelete: () => onDelete(item),
                onQtyAktualChanged: (qty) => onQtyAktualChanged(item, qty),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProdukItemRow extends StatelessWidget {
  const _ProdukItemRow({
    required this.item,
    required this.onDelete,
    required this.onQtyAktualChanged,
  });

  final StokOpnameProdukItem item;
  final VoidCallback onDelete;
  final ValueChanged<int> onQtyAktualChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Text(item.nama, style: AppTypography.textTheme.bodyMedium),
          ),
          const SizedBox(width: AppSpacing.x3),
          _QtyLabel(label: 'Qty Aktual'),
          const SizedBox(width: AppSpacing.x2),
          _QuantityControl(
            value: item.qtyAktual,
            onChanged: onQtyAktualChanged,
          ),
          const SizedBox(width: AppSpacing.x3),
          _QtyLabel(label: 'Qty System'),
          const SizedBox(width: AppSpacing.x2),
          _ReadOnlyBox(value: item.qtySystem),
          const SizedBox(width: AppSpacing.x3),
          _QtyLabel(label: 'Qty Selisih'),
          const SizedBox(width: AppSpacing.x2),
          _ReadOnlyBox(value: item.qtySelisih),
        ],
      ),
    );
  }
}

class _QtyLabel extends StatelessWidget {
  const _QtyLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: Icons.remove_rounded,
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium,
            ),
          ),
          _QtyBtn(
            icon: Icons.add_rounded,
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2),
        child: Icon(
          icon,
          size: 18,
          color: onPressed == null
              ? AppColors.onSurfaceVariant
              : AppColors.onSurface,
        ),
      ),
    );
  }
}

class _ReadOnlyBox extends StatelessWidget {
  const _ReadOnlyBox({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.xs,
      ),
      child: Text(
        '$value',
        style: AppTypography.textTheme.bodyMedium,
      ),
    );
  }
}

// ── Field widgets ─────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  const _DateRow({required this.tanggal, required this.onEdit});

  final DateTime tanggal;
  final VoidCallback onEdit;

  static String _format(DateTime d) {
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${hari[d.weekday - 1]}, ${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 20,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.x3),
          Text(
            'Date',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(_format(tanggal), style: AppTypography.textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.x2),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Text(label, style: AppTypography.textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: AppTypography.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _EditableSection extends StatelessWidget {
  const _EditableSection({
    required this.label,
    required this.value,
    required this.onEdit,
    this.isPlaceholder = false,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            value,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: isPlaceholder
                  ? AppColors.onSurfaceVariant
                  : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit text dialog ──────────────────────────────────────────────────────────

class _EditTextDialog extends StatefulWidget {
  const _EditTextDialog({
    required this.label,
    required this.initial,
    this.multiline = false,
  });

  final String label;
  final String initial;
  final bool multiline;

  @override
  State<_EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<_EditTextDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.label),
      content: TextField(
        controller: _ctrl,
        maxLines: widget.multiline ? 4 : 1,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

// ── Bottom buttons ────────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.onCancel,
    required this.onDraft,
    required this.onPostNow,
  });

  final VoidCallback onCancel;
  final VoidCallback onDraft;
  final VoidCallback onPostNow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _Btn(label: 'Cancel', color: AppColors.error, onPressed: onCancel)),
        Expanded(
            child: _Btn(label: 'Draft', color: Colors.orange, onPressed: onDraft)),
        Expanded(
            child: _Btn(label: 'Post now', color: AppColors.tertiary, onPressed: onPostNow)),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.color, required this.onPressed});

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.onPrimary,
          shape: const RoundedRectangleBorder(),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
        child: Text(label),
      ),
    );
  }
}
