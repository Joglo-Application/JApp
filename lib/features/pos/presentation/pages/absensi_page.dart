import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/drawer/role_drawer.dart';
import '../providers/absensi_provider.dart';

class AbsensiPage extends StatelessWidget {
  const AbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AbsensiProvider(),
      child: const _AbsensiView(),
    );
  }
}

class _AbsensiView extends StatefulWidget {
  const _AbsensiView();

  @override
  State<_AbsensiView> createState() => _AbsensiViewState();
}

class _AbsensiViewState extends State<_AbsensiView> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: roleDrawer(context, absensiActive: true),
      body: SafeArea(
        child: Column(
          children: [
            _AbsensiAppBar(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ColoredBox(
                      color: AppColors.primary,
                      child: _ClockZone(now: _now),
                    ),
                  ),
                  _ActionSection(now: _now),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AbsensiAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(
          bottom: BorderSide(color: AppColors.secondaryContainer),
        ),
      ),
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
              'Absensi',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            _RiwayatButton(),
          ],
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
    return FilledButton(
      onPressed: () => _showRiwayat(context),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
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
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showRiwayat(BuildContext context) {
    final provider = context.read<AbsensiProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _RiwayatSheet(),
      ),
    );
  }
}

// ── Clock zone (yellow) ───────────────────────────────────────────────────────

class _ClockZone extends StatelessWidget {
  const _ClockZone({required this.now});

  final DateTime now;

  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String get _clockStr {
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _dateStr {
    final day = _days[now.weekday - 1];
    final month = _months[now.month - 1];
    return '$day, ${now.day} $month ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '[Nama Restoran]',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        const Icon(
          Icons.people_rounded,
          size: 80,
          color: AppColors.onPrimary,
        ),
        const SizedBox(height: AppSpacing.x6),
        Text(
          _clockStr,
          style: AppTypography.textTheme.displayLarge?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          _dateStr,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Action section (white) ────────────────────────────────────────────────────

class _ActionSection extends StatelessWidget {
  const _ActionSection({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AbsensiProvider>().status;

    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x8,
          vertical: AppSpacing.x6,
        ),
        child: _buildButton(context, status),
      ),
    );
  }

  Widget _buildButton(BuildContext context, AbsensiStatus status) {
    if (status == AbsensiStatus.belumHadir) {
      return _ActionButton(
        label: 'Hadir',
        color: AppColors.primary,
        onPressed: () => _onHadir(context),
      );
    }
    if (status == AbsensiStatus.sudahHadir) {
      return _ActionButton(
        label: 'Pulang',
        color: AppColors.error,
        onPressed: () => _onPulang(context),
      );
    }
    // sudahPulang — disabled
    return _ActionButton(
      label: 'Pulang',
      color: Colors.grey.shade400,
      onPressed: null,
    );
  }

  void _onHadir(BuildContext context) {
    context.read<AbsensiProvider>().hadir();
    showDialog<void>(
      context: context,
      builder: (_) => const _StatusDialog(
        icon: Icons.wb_sunny_rounded,
        message: 'Anda Sudah Hadir',
      ),
    );
  }

  void _onPulang(BuildContext context) {
    context.read<AbsensiProvider>().pulang();
    showDialog<void>(
      context: context,
      builder: (_) => const _StatusDialog(
        icon: Icons.nightlight_round,
        message: 'Anda Sudah Pulang',
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Riwayat sheet ────────────────────────────────────────────────────────────

class _RiwayatSheet extends StatelessWidget {
  const _RiwayatSheet();

  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(DateTime dt) {
    final day = _days[dt.weekday - 1];
    final month = _months[dt.month - 1];
    return '$day,\n${dt.day} $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<AbsensiProvider>().history;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: SizedBox(
                height: 56,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.onPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.surface,
                child: history.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada riwayat',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x4,
                          vertical: AppSpacing.x3,
                        ),
                        itemCount: history.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final record = history[i];
                          final isHadir = record.type == AbsensiStatus.sudahHadir;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.x3,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people_rounded,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.x3),
                                Expanded(
                                  child: Text(
                                    _formatDate(record.waktu),
                                    style: AppTypography.textTheme.bodyMedium,
                                  ),
                                ),
                                FilledButton(
                                  onPressed: null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isHadir
                                        ? Colors.green
                                        : AppColors.error,
                                    disabledBackgroundColor: isHadir
                                        ? Colors.green
                                        : AppColors.error,
                                    foregroundColor: AppColors.onPrimary,
                                    minimumSize: const Size(80, 36),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.md,
                                    ),
                                  ),
                                  child: Text(
                                    isHadir ? 'Hadir' : 'Pulang',
                                    style: AppTypography.textTheme.labelMedium
                                        ?.copyWith(color: AppColors.onPrimary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status dialog ─────────────────────────────────────────────────────────────

class _StatusDialog extends StatelessWidget {
  const _StatusDialog({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x6,
            AppSpacing.x5,
            AppSpacing.x5,
            AppSpacing.x6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 24),
                ),
              ),
              const SizedBox(height: AppSpacing.x2),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.onPrimary, size: 44),
              ),
              const SizedBox(height: AppSpacing.x4),
              Text(
                message,
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.x2),
            ],
          ),
        ),
      ),
    );
  }
}
