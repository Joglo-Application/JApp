import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/log_gudang_remote_datasource.dart';
import '../../domain/entities/log_gudang_entry.dart';

/// Visual style (label, warna, ikon) untuk sebuah jenis log gudang.
typedef _JenisStyle = ({String label, Color color, IconData icon});

_JenisStyle _styleFor(String jenis) {
  switch (jenis.toUpperCase()) {
    case 'ADD_STOK':
      return (label: 'Tambah Stok', color: AppColors.tertiary, icon: Icons.add_box_rounded);
    case 'ADD_QTY_STOK':
      return (label: 'Tambah Qty', color: AppColors.tertiary, icon: Icons.exposure_plus_1_rounded);
    case 'UPDATE_ITEM':
      return (label: 'Ubah Item', color: Color(0xFF2196F3), icon: Icons.edit_rounded);
    case 'DELETE_ITEM':
      return (label: 'Hapus Item', color: AppColors.error, icon: Icons.delete_rounded);
    default:
      return (label: _humanize(jenis), color: AppColors.onSurfaceVariant, icon: Icons.inventory_2_rounded);
  }
}

String _humanize(String raw) => raw
    .split(RegExp(r'[_\s]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

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
      // Terbaru di paling atas.
      final sorted = [...data]..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      setState(() {
        _entries = sorted;
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              count: _entries.length,
              loading: _loading,
              onRefresh: _loading ? null : _load,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _EmptyState(
        icon: Icons.cloud_off_rounded,
        message: _error!,
      );
    }
    if (_entries.isEmpty) {
      return const _EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Belum ada log gudang.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.x4),
      itemCount: _entries.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(
          bottom: index == _entries.length - 1 ? 0 : AppSpacing.x3,
        ),
        child: _LogGudangCard(entry: _entries[index]),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.loading,
    required this.onRefresh,
    required this.onClose,
  });

  final int count;
  final bool loading;
  final VoidCallback? onRefresh;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.tertiary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
          const SizedBox(width: AppSpacing.x3),
          Text(
            'Log Gudang',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          if (!loading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadius.full,
              ),
              child: Text(
                '$count',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Spacer(),
          _HeaderIcon(
            icon: Icons.refresh_rounded,
            tooltip: 'Muat ulang',
            onTap: onRefresh,
          ),
          const SizedBox(width: AppSpacing.x2),
          _HeaderIcon(
            icon: Icons.close_rounded,
            tooltip: 'Tutup',
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sm,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _LogGudangCard extends StatelessWidget {
  const _LogGudangCard({required this.entry});

  final LogGudangEntry entry;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(entry.jenis);
    final dt = entry.tanggal;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(style.icon, size: 20, color: style.color),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.full,
                  ),
                  child: Text(
                    style.label,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: style.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  entry.logs,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.x1),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 13, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      entry.author,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _time(dt),
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _date(dt),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty / error state ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
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
