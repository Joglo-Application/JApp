import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/log_gudang_entry.dart';

class OwnerLogGudangPage extends StatelessWidget {
  const OwnerLogGudangPage({super.key});

  //# API LOG GUDANG - ganti dummy dengan data dari backend
  static final List<LogGudangEntry> _dummyEntries = [
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 9, 0),
      jenis: 'UPDATE_Foto',
      author: 'gudang1',
      logs: 'Menambahkan Foto',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 9, 10),
      jenis: 'UPDATE_Nama',
      author: 'gudang1',
      logs: 'cabe hiaju → cabe hijau',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 9, 20),
      jenis: 'UPDATE_Kategori',
      author: 'gudang1',
      logs: 'Frozen Food → Saos',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 10, 0),
      jenis: 'UPDATE_Stok',
      author: 'gudang1',
      logs: 'Liter → Gram',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 10, 0),
      jenis: 'UPDATE_Stok',
      author: 'gudang1',
      logs: '0 → 10, Update Konverter satuan',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 10, 0),
      jenis: 'UPDATE_Stok',
      author: 'gudang1',
      logs: '1000 → 100, Update Qty stok',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 10, 0),
      jenis: 'UPDATE_Stok',
      author: 'gudang1',
      logs: '25 → 10, Update Qty tahan',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 17, 25),
      jenis: 'DELETE_ITEM',
      author: 'gudang1',
      logs: '→ cabe hijau',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 17, 25),
      jenis: 'UPDATE_ITEM',
      author: 'gudang1',
      logs: 'Update stok cabe hijau',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 17, 25),
      jenis: 'ADD_STOK',
      author: 'gudang1',
      logs: 'Menambahkan cabe merah',
    ),
    LogGudangEntry(
      tanggal: DateTime(2025, 8, 15, 17, 25),
      jenis: 'ADD_QTY_STOK',
      author: 'gudang1',
      logs: '+1000 → cabe hijau',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = _dummyEntries;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleRow(context),
            const _TableHeader(),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada log gudang.',
                        style: AppTypography.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.outlineVariant,
                      ),
                      itemBuilder: (context, index) =>
                          _LogGudangRow(entry: entries[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Log Gudang',
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
}

// ── Header ─────────────────────────────────────────────────────────────────────

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
        child: Row(
          children: const [
            Expanded(
              flex: 3,
              child: _HeaderCell(label: 'Tanggal'),
            ),
            Expanded(
              flex: 2,
              child: _HeaderCell(label: 'Jenis'),
            ),
            Expanded(
              flex: 2,
              child: _HeaderCell(label: 'Author/Nama'),
            ),
            Expanded(
              flex: 3,
              child: _HeaderCell(label: 'Logs'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.textTheme.labelLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Row ────────────────────────────────────────────────────────────────────────

class _LogGudangRow extends StatelessWidget {
  const _LogGudangRow({required this.entry});

  final LogGudangEntry entry;

  static String _formatTanggal(DateTime d) {
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final jam = d.hour.toString().padLeft(2, '0');
    final menit = d.minute.toString().padLeft(2, '0');
    return '${hari[d.weekday - 1]}, ${d.day} ${bulan[d.month - 1]} '
        '${d.year}, $jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    final cellStyle = AppTypography.textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurface,
      fontWeight: FontWeight.w500,
    );

    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(_formatTanggal(entry.tanggal), style: cellStyle),
            ),
            Expanded(
              flex: 2,
              child: Text(entry.jenis, style: cellStyle),
            ),
            Expanded(
              flex: 2,
              child: Text(entry.author, style: cellStyle),
            ),
            Expanded(
              flex: 3,
              child: Text(entry.logs, style: cellStyle),
            ),
          ],
        ),
      ),
    );
  }
}
