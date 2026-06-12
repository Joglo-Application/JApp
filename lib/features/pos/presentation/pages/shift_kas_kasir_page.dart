import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/shift_kas_provider.dart';
import '../widgets/navigation/pos_drawer.dart';
import '../widgets/shift_kas/shift_kas_app_bar.dart';

class ShiftKasKasirPage extends StatelessWidget {
  const ShiftKasKasirPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShiftKasProvider(),
      child: const _ShiftKasView(),
    );
  }
}

class _ShiftKasView extends StatelessWidget {
  const _ShiftKasView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PosDrawer(activePage: PosDrawerPage.shiftKas),
      floatingActionButton: _AddEntryFab(),
      body: SafeArea(
        child: Column(
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
    if (!provider.shiftStarted) {
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
      padding: const EdgeInsets.all(AppSpacing.x4),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.x2),
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
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

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
    final isSetoran = entry.jenis == ShiftKasJenis.setoran;
    final selected =
        context.watch<ShiftKasProvider>().selected?.id == entry.id;

    return GestureDetector(
      onTap: () => context.read<ShiftKasProvider>().select(entry),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade200,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSetoran
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSetoran
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isSetoran ? Colors.green.shade700 : Colors.red.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.keterangan,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDate(entry.waktu)}  ${_formatTime(entry.waktu)}',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isSetoran ? '+' : '-'} ${_formatRp(entry.jumlah)}',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: isSetoran ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
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
    final entries = provider.entries;

    final totalSetoran = entries
        .where((e) => e.jenis == ShiftKasJenis.setoran)
        .fold(0.0, (s, e) => s + e.jumlah);
    final totalPenarikan = entries
        .where((e) => e.jenis == ShiftKasJenis.penarikan)
        .fold(0.0, (s, e) => s + e.jumlah);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: selected == null
          ? _PanelSummary(
              totalSetoran: totalSetoran,
              totalPenarikan: totalPenarikan,
              totalKas: provider.totalKas,
              formatRp: _formatRp,
            )
          : _PanelDetail(entry: selected, formatRp: _formatRp),
    );
  }
}

class _PanelSummary extends StatelessWidget {
  const _PanelSummary({
    required this.totalSetoran,
    required this.totalPenarikan,
    required this.totalKas,
    required this.formatRp,
  });

  final double totalSetoran;
  final double totalPenarikan;
  final double totalKas;
  final String Function(double) formatRp;

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              'Ringkasan Shift',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Column(
            children: [
              _SummaryRow(
                label: 'Total Setoran',
                value: formatRp(totalSetoran),
                valueColor: Colors.green.shade700,
              ),
              const SizedBox(height: AppSpacing.x3),
              _SummaryRow(
                label: 'Total Penarikan',
                value: formatRp(totalPenarikan),
                valueColor: Colors.red.shade700,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.x3),
                child: Divider(height: 1),
              ),
              _SummaryRow(
                label: 'Total Kas',
                value: formatRp(totalKas),
                valueColor: AppColors.primary,
                bold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
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
                value: isSetoran ? 'Setoran' : 'Penarikan',
                valueColor: isSetoran ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(height: AppSpacing.x3),
              _DetailField(label: 'Keterangan', value: entry.keterangan),
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
                      onTap: () {
                        context.read<ShiftKasProvider>().mulaiShift(kasAwal);
                        Navigator.of(context).pop();
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

class _AddEntryDialog extends StatefulWidget {
  const _AddEntryDialog();

  @override
  State<_AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<_AddEntryDialog> {
  ShiftKasJenis _jenis = ShiftKasJenis.setoran;
  final _keteranganCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();

  @override
  void dispose() {
    _keteranganCtrl.dispose();
    _jumlahCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final keterangan = _keteranganCtrl.text.trim();
    final jumlah = double.tryParse(
      _jumlahCtrl.text.trim().replaceAll('.', '').replaceAll(',', ''),
    );
    if (keterangan.isEmpty || jumlah == null || jumlah <= 0) return;

    context.read<ShiftKasProvider>().addEntry(
          jenis: _jenis,
          keterangan: keterangan,
          jumlah: jumlah,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: ColoredBox(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                    vertical: AppSpacing.x3,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                        child: Text(
                          'Tambah Kas',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.onPrimary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenis',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Row(
                    children: ShiftKasJenis.values.map((j) {
                      final isSelected = _jenis == j;
                      final label =
                          j == ShiftKasJenis.setoran ? 'Setoran' : 'Penarikan';
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: j == ShiftKasJenis.setoran ? AppSpacing.x2 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _jenis = j),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: AppRadius.md,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: AppTypography.textTheme.labelLarge
                                    ?.copyWith(
                                  color: isSelected
                                      ? AppColors.onPrimary
                                      : AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  TextField(
                    controller: _keteranganCtrl,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  TextField(
                    controller: _jumlahCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Batal',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _submit,
                    child: Container(
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
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
