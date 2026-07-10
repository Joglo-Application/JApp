import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/log_gudang_remote_datasource.dart';
import '../../domain/entities/log_gudang_entry.dart';

class OwnerLogGudangPage extends StatefulWidget {
  const OwnerLogGudangPage({super.key});

  @override
  State<OwnerLogGudangPage> createState() => _OwnerLogGudangPageState();
}

class _OwnerLogGudangPageState extends State<OwnerLogGudangPage> {
  final _datasource = LogGudangRemoteDatasourceImpl();
  List<LogGudangEntry> _entries = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _datasource.fetchLogs();
      if (!mounted) return;
      setState(() {
        _entries = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat log gudang.';
        _loading = false;
      });
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
            _buildTitleRow(context),
            const _TableHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: AppTypography.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        )
                      : _entries.isEmpty
                          ? Center(
                              child: Text(
                                'Belum ada log gudang.',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                        color: AppColors.onSurfaceVariant),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _entries.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.outlineVariant,
                              ),
                              itemBuilder: (context, index) =>
                                  _LogGudangRow(entry: _entries[index]),
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
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            iconSize: 22,
            tooltip: 'Muat ulang',
          ),
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
