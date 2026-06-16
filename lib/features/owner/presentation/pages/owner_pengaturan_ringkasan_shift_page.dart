import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Owner-facing report of every cashier shift — date-range filter, search,
/// Excel export, and a tappable list that opens [_ShiftDetailDialog] with
/// the full cash breakdown for that shift.
class OwnerPengaturanRingkasanShiftPage extends StatefulWidget {
  const OwnerPengaturanRingkasanShiftPage({super.key});

  @override
  State<OwnerPengaturanRingkasanShiftPage> createState() =>
      _OwnerPengaturanRingkasanShiftPageState();
}

class _OwnerPengaturanRingkasanShiftPageState
    extends State<OwnerPengaturanRingkasanShiftPage> {
  final _searchController = TextEditingController();
  DateTimeRange _range = DateTimeRange(
    start: DateTime(2025, 8, 1),
    end: DateTime(2025, 8, 31),
  );
  String _query = '';

  static final _rows = [
    _ShiftRow(
      tanggal: DateTime(2025, 8, 14),
      kasir: 'Kasir01',
      mulai: '12:01:23',
      berakhir: '18:03:23',
      kasMasuk: 1000000,
      kasKeluar: -200000,
      totalDiharapkan: 800000,
      penjualanTunai: 0,
      pengembalianTunai: 0,
      pembatalanTunai: 0,
      kasMasukKeluar: -200000,
      kasSelisih: -200000,
    ),
  ];

  List<_ShiftRow> get _filteredRows {
    if (_query.isEmpty) return _rows;
    final q = _query.toLowerCase();
    return _rows.where((r) => r.kasir.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            _buildFilterBar(context),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Ringkasan Shift',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: AppRadius.full,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter bar ──────────────────────────────────────────────────────────

  Widget _buildFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.onSurfaceVariant,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.outline),
                borderRadius: AppRadius.sm,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari',
                  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          const Icon(
            Icons.sort_rounded,
            color: AppColors.onSurfaceVariant,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.x3),
          Text(
            _formatRange(_range),
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          _SquareIconButton(
            icon: Icons.calendar_month_rounded,
            onTap: () => _pickDateRange(context),
          ),
          const SizedBox(width: AppSpacing.x2),
          _ExportButton(onTap: () => _exportExcel(context)),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _range,
    );
    if (picked != null && mounted) {
      setState(() => _range = picked);
    }
  }

  void _exportExcel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Berkas berhasil diunduh',
          style: TextStyle(color: AppColors.onTertiary),
        ),
        backgroundColor: AppColors.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Table ───────────────────────────────────────────────────────────────

  Widget _buildTable() {
    final rows = _filteredRows;

    return Column(
      children: [
        const _TableHeader(),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                  itemBuilder: (context, i) => _ShiftRowTile(
                    row: rows[i],
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => _ShiftDetailDialog(row: rows[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Formatting helpers ───────────────────────────────────────────────────────

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String _formatDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}';

String _formatRange(DateTimeRange r) =>
    '${_formatDate(r.start)} - ${_formatDate(r.end)}';

String _formatTanggalShort(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.year}';

String _formatNum(num amount) {
  final negative = amount < 0;
  final s = amount.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return negative ? '-$buf' : buf.toString();
}

// ── Row model ────────────────────────────────────────────────────────────────

class _ShiftRow {
  const _ShiftRow({
    required this.tanggal,
    required this.kasir,
    required this.mulai,
    required this.berakhir,
    required this.kasMasuk,
    required this.kasKeluar,
    required this.totalDiharapkan,
    required this.penjualanTunai,
    required this.pengembalianTunai,
    required this.pembatalanTunai,
    required this.kasMasukKeluar,
    required this.kasSelisih,
  });

  final DateTime tanggal;
  final String kasir;
  final String mulai;
  final String berakhir;
  final num kasMasuk;
  final num kasKeluar;
  final num totalDiharapkan;
  final num penjualanTunai;
  final num pengembalianTunai;
  final num pembatalanTunai;
  final num kasMasukKeluar;
  final num kasSelisih;
}

// ── Table header ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.outline,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: const Row(
          children: [
            Expanded(flex: 2, child: _HeaderCell('Tanggal')),
            Expanded(flex: 2, child: _HeaderCell('Kasir')),
            Expanded(child: _HeaderCell('Mulai')),
            Expanded(child: _HeaderCell('Berakhir')),
            Expanded(
              flex: 2,
              child: _HeaderCell('Kas Masuk', align: TextAlign.right),
            ),
            Expanded(
              flex: 2,
              child: _HeaderCell('Kas Keluar', align: TextAlign.right),
            ),
            Expanded(
              flex: 2,
              child: _HeaderCell('Total Diharapkan', align: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.align = TextAlign.left});

  final String label;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: AppTypography.textTheme.labelLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Table row ────────────────────────────────────────────────────────────────

class _ShiftRowTile extends StatelessWidget {
  const _ShiftRowTile({required this.row, required this.onTap});

  final _ShiftRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurface,
    );

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(_formatDate(row.tanggal), style: style),
              ),
              Expanded(flex: 2, child: Text(row.kasir, style: style)),
              Expanded(child: Text(row.mulai, style: style)),
              Expanded(child: Text(row.berakhir, style: style)),
              Expanded(
                flex: 2,
                child: Text(
                  _formatNum(row.kasMasuk),
                  textAlign: TextAlign.right,
                  style: style,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _formatNum(row.kasKeluar),
                  textAlign: TextAlign.right,
                  style: style,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _formatNum(row.totalDiharapkan),
                  textAlign: TextAlign.right,
                  style: style,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filter bar buttons ───────────────────────────────────────────────────────

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sm,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.onPrimary, size: 20),
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.onTap});

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
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x2 + 2,
          ),
          child: Text(
            'Export Excel',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Detail dialog ────────────────────────────────────────────────────────────

class _ShiftDetailDialog extends StatelessWidget {
  const _ShiftDetailDialog({required this.row});

  final _ShiftRow row;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5,
                AppSpacing.x4,
                AppSpacing.x5,
                AppSpacing.x4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _LabelValue(
                      label: 'Kasir',
                      value: row.kasir,
                    ),
                  ),
                  Expanded(
                    child: _LabelValue(
                      label: 'Tanggal',
                      value: _formatTanggalShort(row.tanggal),
                      align: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            _DialogBar(
              label: 'Kas Masuk',
              value: _formatNum(row.kasMasuk),
              background: AppColors.background,
              foreground: AppColors.onSurface,
              bold: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x5,
                vertical: AppSpacing.x4,
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Penjualan Tunai',
                    value: _formatNum(row.penjualanTunai),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _DetailRow(
                    label: 'Pengembalian Tunai',
                    value: _formatNum(row.pengembalianTunai),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _DetailRow(
                    label: 'Pembatalan Tunai',
                    value: _formatNum(row.pembatalanTunai),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _DetailRow(
                    label: 'Kas Masuk-Keluar',
                    value: _formatNum(row.kasMasukKeluar),
                  ),
                ],
              ),
            ),
            _DialogBar(
              label: 'Total Diharapkan',
              value: _formatNum(row.totalDiharapkan),
              background: AppColors.tertiary,
              foreground: AppColors.onTertiary,
              bold: true,
            ),
            _DialogBar(
              label: 'Kas Selisih',
              value: _formatNum(row.kasSelisih),
              background: AppColors.error,
              foreground: AppColors.onError,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Detail Shift',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.onPrimary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({
    required this.label,
    required this.value,
    this.align = TextAlign.left,
  });

  final String label;
  final String value;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: align,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          value,
          textAlign: align,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            'IDR',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogBar extends StatelessWidget {
  const _DialogBar({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              value,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
