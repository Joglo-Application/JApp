import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/thousands_separator_input_formatter.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/shift_kas_provider.dart';
import '../widgets/navigation/pos_drawer.dart';
import '../widgets/shift_kas/shift_kas_app_bar.dart';

class ShiftKasKasirPage extends StatelessWidget {
  const ShiftKasKasirPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShiftKasProvider()..load(),
      child: _ShiftKasView(drawer: drawer),
    );
  }
}

class _ShiftKasView extends StatelessWidget {
  const _ShiftKasView({this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer ?? const PosDrawer(activePage: PosDrawerPage.shiftKas),
      floatingActionButton: _AddEntryFab(),
      body: Column(
        children: [
          const ShiftKasAppBar(),
          Expanded(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const _EntriesList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _AddEntryFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _onPressed(context),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }

  void _onPressed(BuildContext context) {
    final provider = context.read<ShiftKasProvider>();
    if (!provider.hasShift) {
      showDialog<void>(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const _KasAwalDialog(),
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const _AddEntryDialog(),
        ),
      );
    }
  }
}

// ── Entries list ──────────────────────────────────────────────────────────────

class _EntriesList extends StatelessWidget {
  const _EntriesList();

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<ShiftKasProvider>().entries;
    if (entries.isEmpty) return const _EmptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.x4),
      itemCount: entries.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.x2),
        child: _EntryTile(entry: entries[i]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'Belum ada data kas',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Tekan + untuk menambah setoran atau penarikan',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final ShiftKasEntry entry;

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  static String _formatRp(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer('Rp ');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isMasuk = entry.jenis == ShiftKasJenis.setoran;
    final color = isMasuk ? Colors.green.shade600 : Colors.red.shade600;
    final adaLampiran =
        entry.lampiranUrl != null && entry.lampiranUrl!.isNotEmpty;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () {
          final provider = context.read<ShiftKasProvider>();
          showDialog<void>(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: _EntryDetailDialog(entry: entry),
            ),
          );
        },
        borderRadius: AppRadius.md,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.x3),
          decoration: BoxDecoration(
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.md,
                ),
                child: Icon(
                  isMasuk ? Icons.add_rounded : Icons.remove_rounded,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.namaTransaksi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (adaLampiran) ...[
                          const SizedBox(width: AppSpacing.x1),
                          Icon(
                            Icons.attach_file_rounded,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(entry.waktu),
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (entry.catatan.isNotEmpty)
                      Text(
                        entry.catatan,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Text(
                '${isMasuk ? '+' : '−'} ${_formatRp(entry.jumlah)}',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: color,
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

// ── Lampiran ─────────────────────────────────────────────────────────────────

class _LampiranThumbnail extends StatelessWidget {
  const _LampiranThumbnail({required this.path});

  /// Path relatif dari server, mis. `/uploads/xxx.jpg`.
  final String path;

  String get _url {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final origin = Uri.parse(ApiConfig.baseUrl).origin;
    return '$origin${path.startsWith('/') ? '' : '/'}$path';
  }

  void _viewFull(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(AppSpacing.x4),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(child: Image.network(_url, fit: BoxFit.contain)),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _viewFull(context),
      child: ClipRRect(
        borderRadius: AppRadius.md,
        child: Image.network(
          _url,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            height: 160,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Icon(Icons.broken_image_rounded,
                color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

// ── Kas Awal dialog (step 1) ──────────────────────────────────────────────────

class _KasAwalDialog extends StatefulWidget {
  const _KasAwalDialog();

  @override
  State<_KasAwalDialog> createState() => _KasAwalDialogState();
}

class _KasAwalDialogState extends State<_KasAwalDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    final jumlah = double.tryParse(
      _ctrl.text.trim().replaceAll('.', '').replaceAll(',', ''),
    );
    if (jumlah == null || jumlah < 0) return;

    final provider = context.read<ShiftKasProvider>();
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: _MulaiShiftConfirmDialog(kasAwal: jumlah),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x4,
            AppSpacing.x5,
            AppSpacing.x5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kas Awal di Laci',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x4),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: const [ThousandsSeparatorInputFormatter()],
                style: AppTypography.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: '0',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onSubmitted: (_) => _next(),
              ),
              const SizedBox(height: AppSpacing.x5),
              FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade500,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                ),
                child: Text(
                  'Mulai Shift',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mulai shift confirmation dialog (step 2) ──────────────────────────────────

class _MulaiShiftConfirmDialog extends StatelessWidget {
  const _MulaiShiftConfirmDialog({required this.kasAwal});

  final double kasAwal;

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String _formatRp(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year} $h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x6,
                AppSpacing.x5,
                AppSpacing.x6,
                AppSpacing.x5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mulai Shift',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x5),
                  _ConfirmRow(
                    label: 'Mulai pada',
                    value: _formatDateTime(now),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.x4),
                    child: Divider(height: 1),
                  ),
                  _ConfirmRow(
                    label: 'Kas Mulai',
                    value: _formatRp(kasAwal),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final provider = context.read<ShiftKasProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final conflict = await provider.mulaiShift(kasAwal);
                        if (!context.mounted) return;
                        navigator.pop();
                        final rootContext = navigator.context;
                        if (conflict != null && rootContext.mounted) {
                          showDialog<void>(
                            context: rootContext,
                            builder: (_) =>
                                _ShiftAktifDialog(conflict: conflict),
                          );
                        } else if (provider.error != null) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(provider.error!)),
                          );
                        }
                      },
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Konfirmasi',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog peringatan: masih ada shift aktif di tanggal lain saat mencoba
/// memulai shift baru. Menyebut tanggal shift yang masih aktif.
class _ShiftAktifDialog extends StatelessWidget {
  const _ShiftAktifDialog({required this.conflict});

  final ActiveShiftConflict conflict;

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final tanggal = conflict.tanggal;
    const amber = Color(0xFFB45309);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x6,
                AppSpacing.x6,
                AppSpacing.x6,
                AppSpacing.x5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: amber.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: amber,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  Text(
                    'Shift Masih Aktif',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    'Tidak dapat memulai shift baru',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x5),
                  if (tanggal != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.x4),
                      decoration: BoxDecoration(
                        color: amber.withValues(alpha: 0.08),
                        borderRadius: AppRadius.md,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Shift aktif sejak',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            _formatDate(tanggal),
                            style:
                                AppTypography.textTheme.titleMedium?.copyWith(
                              color: amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.x4),
                  Text(
                    tanggal != null
                        ? 'Tutup dulu shift tanggal ${_formatDate(tanggal)} '
                            'sebelum memulai shift baru.'
                        : conflict.message,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: Text(
                  'Mengerti',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.textTheme.bodyMedium),
        Text(value, style: AppTypography.textTheme.bodyMedium),
      ],
    );
  }
}

// ── Add entry dialog (after shift started) ────────────────────────────────────

enum _KasTab { masuk, keluar }

class _AddEntryDialog extends StatefulWidget {
  const _AddEntryDialog();

  @override
  State<_AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<_AddEntryDialog> {
  _KasTab _tab = _KasTab.masuk;
  final _namaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  final _picker = ImagePicker();
  XFile? _lampiran;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLampiran() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f != null && mounted) setState(() => _lampiran = f);
  }

  Future<void> _submit() async {
    final nama = _namaCtrl.text.trim();
    final jumlah = double.tryParse(
      _jumlahCtrl.text.trim().replaceAll('.', '').replaceAll(',', ''),
    );
    if (nama.isEmpty || jumlah == null || jumlah <= 0) return;

    final provider = context.read<ShiftKasProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Unggah lampiran dulu (bila ada); batalkan simpan jika gagal.
    String? lampiranUrl;
    if (_lampiran != null) {
      final bytes = await _lampiran!.readAsBytes();
      lampiranUrl = await provider.uploadLampiran(bytes, _lampiran!.name);
      if (!mounted) return;
      if (lampiranUrl == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Gagal mengunggah lampiran')),
        );
        return;
      }
    }

    await provider.addEntry(
      jenis: _tab == _KasTab.masuk ? ShiftKasJenis.setoran : ShiftKasJenis.penarikan,
      namaTransaksi: nama,
      jumlah: jumlah,
      catatan: _catatanCtrl.text.trim(),
      lampiranUrl: lampiranUrl,
    );
    if (!mounted) return;
    navigator.pop();
    if (provider.error != null) {
      messenger.showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab selector
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = _KasTab.masuk),
                      child: ColoredBox(
                        color: _tab == _KasTab.masuk ? Colors.white : Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
                          child: Text(
                            'Kas Masuk',
                            textAlign: TextAlign.center,
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: _tab == _KasTab.masuk ? FontWeight.bold : FontWeight.normal,
                              color: _tab == _KasTab.masuk ? AppColors.onSurface : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 56, color: Colors.grey.shade300),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = _KasTab.keluar),
                      child: ColoredBox(
                        color: _tab == _KasTab.keluar ? Colors.white : Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
                          child: Text(
                            'Kas Keluar',
                            textAlign: TextAlign.center,
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: _tab == _KasTab.keluar ? FontWeight.bold : FontWeight.normal,
                              color: _tab == _KasTab.keluar ? AppColors.onSurface : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Form fields
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5, AppSpacing.x5, AppSpacing.x5, AppSpacing.x4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Transaksi',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextField(
                    controller: _namaCtrl,
                    autofocus: true,
                    style: AppTypography.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Text(
                    'Nominal',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextField(
                    controller: _jumlahCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [ThousandsSeparatorInputFormatter()],
                    style: AppTypography.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      prefixText: 'Rp  ',
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Text(
                    'Catatan',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextField(
                    controller: _catatanCtrl,
                    style: AppTypography.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  InkWell(
                    onTap: _pickLampiran,
                    borderRadius: AppRadius.md,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: AppRadius.md,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x3,
                          vertical: AppSpacing.x3,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _lampiran == null
                                  ? Icons.attach_file_rounded
                                  : Icons.image_rounded,
                              size: 20,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.x2),
                            Expanded(
                              child: Text(
                                _lampiran?.name ?? 'File Lampiran',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    AppTypography.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: _lampiran == null
                                      ? AppColors.onSurfaceVariant
                                      : AppColors.onSurface,
                                ),
                              ),
                            ),
                            if (_lampiran != null)
                              GestureDetector(
                                onTap: () => setState(() => _lampiran = null),
                                child: const Icon(Icons.close_rounded, size: 20),
                              )
                            else
                              const Icon(Icons.add_rounded, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                          right: BorderSide(color: Colors.grey.shade200),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Batal',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _submit,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Simpan',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

// ── Entry detail / edit dialog ────────────────────────────────────────────────

class _EntryDetailDialog extends StatefulWidget {
  const _EntryDetailDialog({required this.entry});

  final ShiftKasEntry entry;

  @override
  State<_EntryDetailDialog> createState() => _EntryDetailDialogState();
}

class _EntryDetailDialogState extends State<_EntryDetailDialog> {
  late final TextEditingController _namaCtrl;
  late final TextEditingController _jumlahCtrl;
  late final TextEditingController _catatanCtrl;

  static String _formatNum(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.entry.namaTransaksi);
    _jumlahCtrl = TextEditingController(text: _formatNum(widget.entry.jumlah));
    _catatanCtrl = TextEditingController(text: widget.entry.catatan);
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final nama = _namaCtrl.text.trim();
    final jumlah = double.tryParse(
      _jumlahCtrl.text.trim().replaceAll('.', '').replaceAll(',', ''),
    );
    if (nama.isEmpty || jumlah == null || jumlah <= 0) return;

    context.read<ShiftKasProvider>().updateEntry(
      widget.entry.id,
      namaTransaksi: nama,
      jumlah: jumlah,
      catatan: _catatanCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }

  void _delete() {
    context.read<ShiftKasProvider>().deleteEntry(widget.entry.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMasuk = widget.entry.jenis == ShiftKasJenis.setoran;
    final headerColor = isMasuk ? Colors.green.shade500 : Colors.red.shade500;
    final title = isMasuk ? 'Kas Masuk' : 'Kas Keluar';

    final fieldDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide(color: headerColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x3,
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: ColoredBox(
                color: headerColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                    vertical: AppSpacing.x4,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        title,
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Form fields
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5, AppSpacing.x5, AppSpacing.x5, AppSpacing.x4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Transaksi',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextField(
                    controller: _namaCtrl,
                    style: AppTypography.textTheme.bodyLarge,
                    decoration: fieldDecoration,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Text(
                    'Nominal',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextField(
                    controller: _jumlahCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [ThousandsSeparatorInputFormatter()],
                    style: AppTypography.textTheme.bodyLarge,
                    decoration: fieldDecoration.copyWith(prefixText: 'Rp  '),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Text(
                    'Catatan',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextField(
                    controller: _catatanCtrl,
                    style: AppTypography.textTheme.bodyLarge,
                    decoration: fieldDecoration,
                  ),
                  if (widget.entry.lampiranUrl != null &&
                      widget.entry.lampiranUrl!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      'Lampiran',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    _LampiranThumbnail(path: widget.entry.lampiranUrl!),
                  ],
                ],
              ),
            ),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _delete,
                    child: Container(
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Hapus Transaksi',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _save,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Simpan',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
