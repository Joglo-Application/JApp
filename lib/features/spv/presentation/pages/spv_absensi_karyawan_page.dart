import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/absensi_remote_datasource.dart';
import '../../domain/entities/absensi_record.dart';
import '../widgets/navigation/spv_drawer.dart';

class SpvAbsensiKaryawanPage extends StatefulWidget {
  const SpvAbsensiKaryawanPage({super.key});

  @override
  State<SpvAbsensiKaryawanPage> createState() =>
      _SpvAbsensiKaryawanPageState();
}

class _SpvAbsensiKaryawanPageState extends State<SpvAbsensiKaryawanPage> {
  final _searchCtrl = TextEditingController();
  final _datasource = AbsensiRemoteDatasourceImpl();
  String _searchQuery = '';
  DateTime? _selectedDate;
  List<AbsensiRecord> _records = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _datasource.fetchAbsensi(date: _selectedDate);
      if (!mounted) return;
      setState(() {
        _records = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _records = const [];
        _loading = false;
      });
    }
  }

  List<AbsensiRecord> get _filtered {
    if (_searchQuery.isEmpty) return _records;
    return _records
        .where((r) =>
            r.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _load();
    }
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Berhasil Export data',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.tertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SpvDrawer(activePage: SpvDrawerPage.absensiKaryawan),
      body: SafeArea(
        child: Column(
          children: [
            const _AbsensiKaryawanAppBar(),
            _buildFilterBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : records.isEmpty
                      ? const _EmptyState()
                      : _AbsensiList(records: records),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (q) => setState(() => _searchQuery = q),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari',
                  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x3,
                    vertical: AppSpacing.x2,
                  ),
                  isDense: true,
                  filled: false,
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
                    borderSide:
                        const BorderSide(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            const Icon(
              Icons.sort_rounded,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.x4),
            Material(
              color: AppColors.primary,
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: AppRadius.md,
                child: const SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.onPrimary,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Material(
              color: AppColors.primary,
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: _exportExcel,
                borderRadius: AppRadius.md,
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                  ),
                  child: Text(
                    'Export Excel',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
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
    );
  }
}

class _AbsensiKaryawanAppBar extends StatelessWidget {
  const _AbsensiKaryawanAppBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(bottom: BorderSide(color: AppColors.secondaryContainer)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Material(
              color: AppColors.primary,
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: AppRadius.md,
                child: const SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.menu_rounded,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Text(
              'Absensi Karyawan',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List ───────────────────────────────────────────────────────────────────────

class _AbsensiList extends StatelessWidget {
  const _AbsensiList({required this.records});

  final List<AbsensiRecord> records;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ColoredBox(
          color: AppColors.surface,
          child: Column(
            children: [
              for (var i = 0; i < records.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                _AbsensiRow(record: records[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AbsensiRow extends StatelessWidget {
  const _AbsensiRow({required this.record});

  final AbsensiRecord record;

  static String _formatTanggal(DateTime d) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              record.nama,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatTanggal(record.tanggal),
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
          _TimeChip(label: record.jamMasuk),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.x3),
            child: Text('-'),
          ),
          _TimeChip(label: record.jamKeluar),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: AppRadius.md,
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
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
            Icons.account_circle_rounded,
            size: 64,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'Belum ada data absensi karyawan',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
