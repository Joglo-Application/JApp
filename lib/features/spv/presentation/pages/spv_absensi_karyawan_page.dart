import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/absensi_remote_datasource.dart';
import '../../domain/entities/absensi_record.dart';
import '../widgets/navigation/spv_drawer.dart';

const _kAvatarColors = [
  AppColors.primary,
  AppColors.tertiary,
  Color(0xFF2196F3),
  AppColors.warning,
  Color(0xFF7E57C2),
];

Color _avatarColor(String name) =>
    _kAvatarColors[name.hashCode.abs() % _kAvatarColors.length];

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final p = parts.first;
    return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// "04:59:35" → "04:59"; melewatkan placeholder "-".
String _shortTime(String t) =>
    t.length >= 5 && t.contains(':') ? t.substring(0, 5) : t;

class SpvAbsensiKaryawanPage extends StatefulWidget {
  const SpvAbsensiKaryawanPage({super.key});

  @override
  State<SpvAbsensiKaryawanPage> createState() => _SpvAbsensiKaryawanPageState();
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
      // Terbaru di paling atas.
      final sorted = [...data]..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      setState(() {
        _records = sorted;
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
    final q = _searchQuery.toLowerCase();
    return _records.where((r) => r.nama.toLowerCase().contains(q)).toList();
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

  Future<void> _clearDate() async {
    setState(() => _selectedDate = null);
    await _load();
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
            _AppBar(count: _loading ? null : records.length),
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
    final dateLabel = _selectedDate == null
        ? 'Semua Tanggal'
        : _formatDate(_selectedDate!);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (q) => setState(() => _searchQuery = q),
                      textAlignVertical: TextAlignVertical.center,
                      style: AppTypography.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Cari nama karyawan',
                        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        isCollapsed: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    InkWell(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          // Date filter pill
          Material(
            color: _selectedDate == null
                ? AppColors.background
                : AppColors.primaryContainer,
            borderRadius: AppRadius.md,
            child: InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.md,
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: _selectedDate == null
                        ? AppColors.outlineVariant
                        : AppColors.primary,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: AppColors.onSurface,
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Text(
                      dateLabel,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: AppSpacing.x2),
                      InkWell(
                        onTap: _clearDate,
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          // Export
          Material(
            color: AppColors.tertiary,
            borderRadius: AppRadius.md,
            child: InkWell(
              onTap: _exportExcel,
              borderRadius: AppRadius.md,
              child: Container(
                height: 45,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.file_download_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Text(
                      'Export Excel',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${d.day} ${bulan[d.month - 1]} ${d.year}';
}

class _AppBar extends StatelessWidget {
  const _AppBar({this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
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
            if (count != null) ...[
              const SizedBox(width: AppSpacing.x3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadius.full,
                ),
                child: Text(
                  '$count karyawan',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.x4),
      itemCount: records.length,
      itemBuilder: (context, i) => Padding(
        padding: EdgeInsets.only(
          bottom: i == records.length - 1 ? 0 : AppSpacing.x3,
        ),
        child: _AbsensiCard(record: records[i]),
      ),
    );
  }
}

class _AbsensiCard extends StatelessWidget {
  const _AbsensiCard({required this.record});

  final AbsensiRecord record;

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(record.nama);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(record.nama),
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(record.tanggal),
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
          // Masuk / Keluar
          _TimeBlock(
            label: 'Masuk',
            time: _shortTime(record.jamMasuk),
            color: AppColors.tertiary,
            icon: Icons.login_rounded,
          ),
          const SizedBox(width: AppSpacing.x2),
          _TimeBlock(
            label: 'Keluar',
            time: _shortTime(record.jamKeluar),
            color: record.jamKeluar == '-'
                ? AppColors.onSurfaceVariant
                : AppColors.error,
            icon: Icons.logout_rounded,
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.label,
    required this.time,
    required this.color,
    required this.icon,
  });

  final String label;
  final String time;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.sm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            Icons.groups_2_outlined,
            size: 56,
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
