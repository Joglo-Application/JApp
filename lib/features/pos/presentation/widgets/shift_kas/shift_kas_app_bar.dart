import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/config/api_config.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../data/models/shift_kas_model.dart';
import '../../providers/shift_kas_provider.dart';

class ShiftKasAppBar extends StatelessWidget {
  const ShiftKasAppBar({super.key});

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
    final date = context.select<ShiftKasProvider, DateTime>(
      (p) => p.selectedDate,
    );
    final totalKas = context.select<ShiftKasProvider, double>(
      (p) => p.totalKas,
    );
    final shiftStarted = context.select<ShiftKasProvider, bool>(
      (p) => p.shiftStarted,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(bottom: BorderSide(color: AppColors.secondaryContainer)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              _HamburgerButton(),
              const SizedBox(width: AppSpacing.x3),
              Text(
                'Shift Kas Kasir',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              _RiwayatButton(),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: GestureDetector(
                  onTap: shiftStarted
                      ? () {
                          final provider = context.read<ShiftKasProvider>();
                          showDialog<void>(
                            context: context,
                            builder: (_) => ChangeNotifierProvider.value(
                              value: provider,
                              child: const _ShiftBerakhirDialog(),
                            ),
                          );
                        }
                      : null,
                  child: _KasBalanceDisplay(label: _formatRp(totalKas)),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Text(
                _formatDate(date),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              _DatePickerButton(currentDate: date),
            ],
          ),
        ),
      ),
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(Icons.menu_rounded, color: AppColors.onPrimary, size: 28),
        ),
      ),
    );
  }
}

class _RiwayatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        final provider = context.read<ShiftKasProvider>();
        showDialog<void>(
          context: context,
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const _RiwayatDialog(),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade400),
        foregroundColor: AppColors.onSecondary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        minimumSize: const Size(0, 45),
      ),
      child: Text(
        'Riwayat',
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.onSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _KasBalanceDisplay extends StatelessWidget {
  const _KasBalanceDisplay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({required this.currentDate});

  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: currentDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null && context.mounted) {
            context.read<ShiftKasProvider>().changeDate(picked);
          }
        },
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(
            Icons.calendar_month_rounded,
            color: AppColors.onPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _ShiftBerakhirDialog extends StatefulWidget {
  const _ShiftBerakhirDialog();

  @override
  State<_ShiftBerakhirDialog> createState() => _ShiftBerakhirDialogState();
}

class _ShiftBerakhirDialogState extends State<_ShiftBerakhirDialog> {
  final DateTime _berakhirPada = DateTime.now();

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year} $h:$m:$s';
  }

  static String _formatNum(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String _formatRp(double amount) => 'Rp ${_formatNum(amount)}';

  Widget _row(String label, String value, {Color? valueColor, bool small = false}) {
    final base =
        small ? AppTypography.textTheme.bodySmall : AppTypography.textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: base?.copyWith(color: AppColors.onSurfaceVariant)),
        Text(
          value,
          style: base?.copyWith(
            color: valueColor ?? AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.read<ShiftKasProvider>();
    final kasAwal = p.kasAwal;
    final masuk = p.totalMasuk;
    final keluar = p.totalKeluar;
    final total = p.totalKas;

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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  Text(
                    'Shift Berakhir',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    'Periksa ringkasan sebelum menutup shift',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x5),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.md,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Sisa Uang di Kas',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x1),
                        Text(
                          _formatRp(total),
                          style: AppTypography.textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _row('Kas Awal', _formatRp(kasAwal)),
                  const SizedBox(height: AppSpacing.x2),
                  _row('Kas Masuk', '+ ${_formatRp(masuk)}',
                      valueColor: Colors.green.shade700),
                  const SizedBox(height: AppSpacing.x2),
                  _row('Kas Keluar', '− ${_formatRp(keluar)}',
                      valueColor: Colors.red.shade600),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.x3),
                    child: Divider(height: 1),
                  ),
                  _row('Berakhir pada', _formatDateTime(_berakhirPada),
                      small: true),
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
                        context.read<ShiftKasProvider>().berakhirShift();
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
                          'Akhiri Shift',
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

// ── Riwayat Shift Kas ─────────────────────────────────────────────────────────

const _riwayatMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _riwayatNum(num amount) {
  final s = amount.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _riwayatRp(num amount) => 'Rp ${_riwayatNum(amount)}';

String _riwayatDate(DateTime dt) =>
    '${dt.day} ${_riwayatMonths[dt.month - 1]} ${dt.year}';

String _riwayatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

class _RiwayatDialog extends StatefulWidget {
  const _RiwayatDialog();

  @override
  State<_RiwayatDialog> createState() => _RiwayatDialogState();
}

class _RiwayatDialogState extends State<_RiwayatDialog> {
  late Future<List<ShiftKasModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ShiftKasProvider>().fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5,
                AppSpacing.x5,
                AppSpacing.x3,
                AppSpacing.x4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Shift Kas',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Daftar shift kas terdahulu',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Flexible(
              child: FutureBuilder<List<ShiftKasModel>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.x8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return _RiwayatEmpty(
                      icon: Icons.cloud_off_rounded,
                      message: 'Gagal memuat riwayat.',
                    );
                  }
                  final shifts = snap.data ?? const <ShiftKasModel>[];
                  if (shifts.isEmpty) {
                    return _RiwayatEmpty(
                      icon: Icons.inbox_rounded,
                      message: 'Belum ada riwayat shift.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    itemCount: shifts.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.x3),
                    itemBuilder: (_, i) => _RiwayatCard(shift: shifts[i]),
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

class _RiwayatEmpty extends StatelessWidget {
  const _RiwayatEmpty({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: AppSpacing.x3),
          Text(
            message,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiwayatCard extends StatefulWidget {
  const _RiwayatCard({required this.shift});

  final ShiftKasModel shift;

  @override
  State<_RiwayatCard> createState() => _RiwayatCardState();
}

class _RiwayatCardState extends State<_RiwayatCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.shift;
    final tanggal = s.tanggal ?? s.waktuMulai;
    final open = s.isOpen;
    final statusColor = open ? Colors.green.shade600 : Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: s.entries.isEmpty
                ? null
                : () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris atas: tanggal + status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _riwayatDate(tanggal),
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Text(
                          open ? 'Aktif' : 'Selesai',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s.namaKasir.isEmpty ? 'Kasir' : s.namaKasir,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        '${s.entries.length} transaksi',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (s.entries.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  // Ringkasan
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.x3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: AppRadius.sm,
                    ),
                    child: Column(
                      children: [
                        _sumRow('Kas Awal', _riwayatRp(s.kasAwal)),
                        const SizedBox(height: AppSpacing.x1),
                        _sumRow('Kas Masuk', '+ ${_riwayatRp(s.totalMasuk)}',
                            valueColor: Colors.green.shade700),
                        const SizedBox(height: AppSpacing.x1),
                        _sumRow('Kas Keluar', '− ${_riwayatRp(s.totalKeluar)}',
                            valueColor: Colors.red.shade600),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.x2),
                          child: Divider(height: 1),
                        ),
                        _sumRow('Total Kas', _riwayatRp(s.totalKas),
                            bold: true, valueColor: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Detail entri (expand)
          if (_expanded && s.entries.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x2,
              ),
              child: Column(
                children: [
                  for (final e in s.entries) _RiwayatEntryRow(entry: e),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sumRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: valueColor ?? AppColors.onSurface,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RiwayatEntryRow extends StatelessWidget {
  const _RiwayatEntryRow({required this.entry});

  final ShiftKasEntry entry;

  @override
  Widget build(BuildContext context) {
    final masuk = entry.jenis == ShiftKasJenis.setoran;
    final color = masuk ? Colors.green.shade700 : Colors.red.shade600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              masuk ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 16,
              color: color,
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
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (entry.lampiranUrl != null &&
                        entry.lampiranUrl!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _showLampiran(context, entry.lampiranUrl!),
                        child: Icon(Icons.attach_file_rounded,
                            size: 14, color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
                Text(
                  _riwayatTime(entry.waktu),
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Text(
            '${masuk ? '+' : '−'} ${_riwayatRp(entry.jumlah)}',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showLampiran(BuildContext context, String path) {
    final origin = Uri.parse(ApiConfig.baseUrl).origin;
    final url = path.startsWith('http') ? path : '$origin$path';
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.x6),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ClipRRect(
            borderRadius: AppRadius.md,
            child: InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  padding: const EdgeInsets.all(AppSpacing.x8),
                  color: AppColors.surface,
                  child: const Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
