import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ColoredBox(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const _EntriesList(),
                  ),
                ),
                const _DetailPanel(),
              ],
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

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, i) => _EntryTile(entry: entries[i]),
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

    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isMasuk ? Colors.green.shade500 : Colors.red.shade500,
                borderRadius: AppRadius.md,
              ),
              child: Icon(
                isMasuk ? Icons.add_rounded : Icons.remove_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(entry.waktu),
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    entry.namaTransaksi,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (entry.catatan.isNotEmpty)
                    Text(
                      entry.catatan,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Text(
              _formatRp(entry.jumlah),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: isMasuk ? AppColors.onSurface : Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail panel ──────────────────────────────────────────────────────────────

class _DetailPanel extends StatelessWidget {
  const _DetailPanel();

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
    final provider = context.watch<ShiftKasProvider>();
    final selected = provider.selected;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: selected == null
          ? const SizedBox.expand()
          : _PanelDetail(entry: selected, formatRp: _formatRp),
    );
  }
}

class _PanelDetail extends StatelessWidget {
  const _PanelDetail({required this.entry, required this.formatRp});

  final ShiftKasEntry entry;
  final String Function(double) formatRp;

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}, $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isSetoran = entry.jenis == ShiftKasJenis.setoran;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: Colors.grey.shade700,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.read<ShiftKasProvider>().clearSelection(),
                  icon: const Icon(Icons.close, color: AppColors.onSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailField(
                label: 'Jenis',
                value: isSetoran ? 'Kas Masuk' : 'Kas Keluar',
                valueColor: isSetoran ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(height: AppSpacing.x3),
              _DetailField(label: 'Nama Transaksi', value: entry.namaTransaksi),
              if (entry.catatan.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.x3),
                _DetailField(label: 'Catatan', value: entry.catatan),
              ],
              const SizedBox(height: AppSpacing.x3),
              _DetailField(
                label: 'Jumlah',
                value: formatRp(entry.jumlah),
                valueColor: isSetoran ? Colors.green.shade700 : Colors.red.shade700,
                bold: true,
              ),
              const SizedBox(height: AppSpacing.x3),
              _DetailField(label: 'Waktu', value: _formatDateTime(entry.waktu)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? AppColors.onSurface,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
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
                        await provider.mulaiShift(kasAwal);
                        if (!context.mounted) return;
                        navigator.pop();
                        if (provider.error != null) {
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

  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
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
    await provider.addEntry(
      jenis: _tab == _KasTab.masuk ? ShiftKasJenis.setoran : ShiftKasJenis.penarikan,
      namaTransaksi: nama,
      jumlah: jumlah,
      catatan: _catatanCtrl.text.trim(),
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
                    'Tipe Transaksi',
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
                  DecoratedBox(
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
                          Expanded(
                            child: Text(
                              'File Lampiran',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.add_rounded, size: 24),
                        ],
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
                    'Tipe Transaksi',
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
                  const SizedBox(height: AppSpacing.x4),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: AppRadius.md,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x3,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'File Lampiran',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Icon(Icons.add_rounded, size: 24),
                        ],
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
