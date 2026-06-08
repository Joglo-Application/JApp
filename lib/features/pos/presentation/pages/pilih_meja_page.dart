import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

enum _MejaStatus { free, occupied, reserved }

// Result returned by _MejaOptionsDialog to tell the page which action to take.
enum _MejaAction { pilih, reservasi }

// Result returned by _ReservasiOptionsDialog.
enum _ReservasiAction { lanjutkan, batalkan }

class _Zone {
  const _Zone({required this.id, required this.name});
  final String id;
  final String name;
}

class _Meja {
  const _Meja({
    required this.id,
    required this.name,
    this.status = _MejaStatus.free,
    this.transactionCount = 0,
    required this.zoneId,
  });
  final String id;
  final String name;
  final _MejaStatus status;
  final int transactionCount;
  final String zoneId;

  bool get isOccupied => status == _MejaStatus.occupied;

  _Meja copyWith({_MejaStatus? status}) => _Meja(
        id: id,
        name: name,
        status: status ?? this.status,
        transactionCount: transactionCount,
        zoneId: zoneId,
      );
}

const _zones = [
  _Zone(id: 'l1', name: 'Lantai 1'),
  _Zone(id: 'l2', name: 'Lantai 2'),
  _Zone(id: 'l3', name: 'Lantai 3'),
  _Zone(id: 'out', name: 'Outdoor'),
];

const _seedTables = [
  _Meja(id: '01', name: '01', zoneId: 'l1'),
  _Meja(id: '02', name: '02', zoneId: 'l1'),
  _Meja(id: '03', name: '03', zoneId: 'l1'),
  _Meja(id: '04', name: '04', zoneId: 'l1'),
  _Meja(id: '05', name: '05', zoneId: 'l1'),
  _Meja(id: '06', name: '06', zoneId: 'l1'),
  _Meja(id: 'lesehan01', name: 'Lesehan 01', status: _MejaStatus.occupied, transactionCount: 2, zoneId: 'l1'),
  _Meja(id: 'taman01', name: 'Taman 01', zoneId: 'l1'),
  _Meja(id: 'l2-01', name: '01', zoneId: 'l2'),
  _Meja(id: 'l2-02', name: '02', zoneId: 'l2'),
  _Meja(id: 'l3-01', name: '01', zoneId: 'l3'),
  _Meja(id: 'out-01', name: 'Garden 01', status: _MejaStatus.occupied, transactionCount: 1, zoneId: 'out'),
  _Meja(id: 'out-02', name: 'Garden 02', zoneId: 'out'),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class PilihMejaPage extends StatefulWidget {
  const PilihMejaPage({super.key});

  @override
  State<PilihMejaPage> createState() => _PilihMejaPageState();
}

class _PilihMejaPageState extends State<PilihMejaPage> {
  int _tabIndex = 0;
  int _zoneIndex = 0;
  _Meja? _selectedMeja;
  late List<_Meja> _tables = List.of(_seedTables);

  List<_Meja> get _filteredTables =>
      _tables.where((m) => m.zoneId == _zones[_zoneIndex].id).toList();

  void _updateTableStatus(String id, _MejaStatus status) {
    setState(() {
      _tables = _tables
          .map((t) => t.id == id ? t.copyWith(status: status) : t)
          .toList();
    });
  }

  Future<void> _onTableTap(_Meja meja) async {
    switch (meja.status) {
      case _MejaStatus.occupied:
        setState(() {
          _selectedMeja = meja;
          _tabIndex = 1;
        });

      case _MejaStatus.reserved:
        final action = await showDialog<_ReservasiAction>(
          context: context,
          builder: (_) => _ReservasiOptionsDialog(meja: meja),
        );
        if (!mounted) return;
        if (action == _ReservasiAction.lanjutkan) {
          Navigator.of(context).pop(meja);
        } else if (action == _ReservasiAction.batalkan) {
          _updateTableStatus(meja.id, _MejaStatus.free);
        }

      case _MejaStatus.free:
        final action = await showDialog<_MejaAction>(
          context: context,
          builder: (_) => _MejaOptionsDialog(meja: meja),
        );
        if (!mounted) return;
        if (action == _MejaAction.pilih) {
          Navigator.of(context).pop(meja);
        } else if (action == _MejaAction.reservasi) {
          _updateTableStatus(meja.id, _MejaStatus.reserved);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade700,
      body: SafeArea(
        child: Column(
          children: [
            _PilihMejaHeader(
              selectedIndex: _tabIndex,
              onTabSelected: (i) => setState(() => _tabIndex = i),
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _tabIndex == 0
                  ? _TableGrid(
                      tables: _filteredTables,
                      onTableTap: _onTableTap,
                    )
                  : _TransaksiMejaContent(meja: _selectedMeja),
            ),
            _ZoneSelector(
              zones: _zones,
              selectedIndex: _zoneIndex,
              onZoneSelected: (i) => setState(() {
                _zoneIndex = i;
                _tabIndex = 0;
                _selectedMeja = null;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PilihMejaHeader extends StatelessWidget {
  const _PilihMejaHeader({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onClose,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(
          bottom: BorderSide(color: AppColors.secondaryContainer),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x2),
            child: Material(
              color: AppColors.primary,
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: () {},
                borderRadius: AppRadius.md,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.sort_rounded,
                    color: AppColors.onPrimary,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _HeaderTabBar(
              selectedIndex: selectedIndex,
              onTabSelected: onTabSelected,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x2),
            child: Material(
              color: AppColors.error,
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: onClose,
                borderRadius: AppRadius.md,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.onError,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTabBar extends StatelessWidget {
  const _HeaderTabBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const _tabs = ['PILIH MEJA', 'TRANSAKSI MEJA'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final isSelected = index == selectedIndex;
        return Expanded(
          child: InkWell(
            onTap: () => onTabSelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                    vertical: AppSpacing.x4,
                  ),
                  child: Text(
                    _tabs[index],
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.onSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Table grid ────────────────────────────────────────────────────────────────

class _TableGrid extends StatelessWidget {
  const _TableGrid({required this.tables, required this.onTableTap});

  final List<_Meja> tables;
  final ValueChanged<_Meja> onTableTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 2.2,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final meja = tables[index];
        return _TableCard(meja: meja, onTap: () => onTableTap(meja));
      },
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.meja, required this.onTap});

  final _Meja meja;
  final VoidCallback onTap;

  static const _reservedColor = Color(0xFF4361EE);

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (meja.status) {
      _MejaStatus.occupied => AppColors.error,
      _MejaStatus.reserved => _reservedColor,
      _MejaStatus.free => AppColors.primary,
    };

    final subtitle = switch (meja.status) {
      _MejaStatus.occupied => '${meja.transactionCount} Transaksi Meja',
      _MejaStatus.reserved => 'Reservasi Meja',
      _MejaStatus.free => null,
    };

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  meja.name,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Transaksi Meja content ────────────────────────────────────────────────────

class _TransaksiMejaContent extends StatelessWidget {
  const _TransaksiMejaContent({this.meja});

  final _Meja? meja;

  @override
  Widget build(BuildContext context) {
    if (meja == null) {
      return Center(
        child: Text(
          'Pilih meja dari tab Pilih Meja',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: Colors.white54,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meja [${meja!.name}]',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Transaksi : ${meja!.transactionCount}',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _TransaksiActionButton(
                      label: 'Kosongkan Meja',
                      color: AppColors.error,
                      onTap: () {},
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    _TransaksiActionButton(
                      label: 'Ganti Meja',
                      color: const Color(0xFF4361EE),
                      icon: Icons.swap_horiz_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    _TransaksiActionButton(
                      label: 'Lihat Transaksi',
                      color: AppColors.onPrimaryContainer,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TransaksiActionButton extends StatelessWidget {
  const _TransaksiActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.x2),
              ],
              Text(
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Meja options dialog ───────────────────────────────────────────────────────

class _MejaOptionsDialog extends StatelessWidget {
  const _MejaOptionsDialog({required this.meja});

  final _Meja meja;

  static const _bodyColor = Color(0xFF8E7210); // dark gold (brandGoldDark)

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.3,
        vertical: AppSpacing.x16,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chair_alt_rounded,
                      color: AppColors.onPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'Meja ${meja.name}',
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
            // Options
            ColoredBox(
              color: _bodyColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MejaOption(
                    icon: Icons.check_rounded,
                    label: 'Pilih Meja',
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => _JumlahTamuDialog(mejaNama: meja.name),
                      );
                      if (confirmed == true && context.mounted) {
                        Navigator.of(context).pop(_MejaAction.pilih);
                      }
                    },
                  ),
                  _MejaOption(
                    icon: Icons.assignment_rounded,
                    label: 'Reservasi Meja',
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => _JumlahTamuDialog(mejaNama: meja.name),
                      );
                      if (confirmed == true && context.mounted) {
                        Navigator.of(context).pop(_MejaAction.reservasi);
                      }
                    },
                  ),
                  _MejaOption(
                    icon: Icons.remove_circle_outline_rounded,
                    label: 'Blokir Meja',
                    onTap: () {},
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

class _MejaOption extends StatelessWidget {
  const _MejaOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(icon, color: AppColors.onPrimary, size: 24),
              ),
            ),
            const SizedBox(width: AppSpacing.x4),
            Text(
              label,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Jumlah tamu dialog ────────────────────────────────────────────────────────

class _JumlahTamuDialog extends StatefulWidget {
  const _JumlahTamuDialog({required this.mejaNama});

  final String mejaNama;

  @override
  State<_JumlahTamuDialog> createState() => _JumlahTamuDialogState();
}

class _JumlahTamuDialogState extends State<_JumlahTamuDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Text(
                    'Meja ${widget.mejaNama}',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x4),
              Text(
                'Mohon masukkan jumlah tamu',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.x3),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nominal Tamu',
                  labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                cursorColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.x6),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'BATAL',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'KONFIRMASI',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reservasi options dialog ──────────────────────────────────────────────────

class _ReservasiOptionsDialog extends StatelessWidget {
  const _ReservasiOptionsDialog({required this.meja});

  final _Meja meja;

  static const _bodyColor = Color(0xFF8E7210);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.3,
        vertical: AppSpacing.x16,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chair_alt_rounded,
                        color: AppColors.onPrimary, size: 22),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'Reservasi Meja ${meja.name}',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon:
                          const Icon(Icons.close, color: AppColors.onPrimary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            // Lanjutkan Pesanan
            Material(
              color: _bodyColor,
              borderRadius: BorderRadius.zero,
              child: InkWell(
                onTap: () =>
                    Navigator.of(context).pop(_ReservasiAction.lanjutkan),
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
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.shopping_cart_rounded,
                              color: AppColors.onPrimary, size: 24),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x4),
                      Text(
                        'Lanjutkan Pesanan',
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Batalkan Reservasi
            Material(
              color: AppColors.error,
              borderRadius: BorderRadius.zero,
              child: InkWell(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => const _PinSupervisorDialog(),
                  );
                  if (confirmed == true && context.mounted) {
                    Navigator.of(context).pop(_ReservasiAction.batalkan);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                    vertical: AppSpacing.x3,
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: AppRadius.md,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.delete_rounded,
                              color: AppColors.error, size: 24),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x4),
                      Text(
                        'Batalkan Reservasi',
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

// ── PIN Supervisor dialog ─────────────────────────────────────────────────────

class _PinSupervisorDialog extends StatefulWidget {
  const _PinSupervisorDialog();

  @override
  State<_PinSupervisorDialog> createState() => _PinSupervisorDialogState();
}

class _PinSupervisorDialogState extends State<_PinSupervisorDialog> {
  String _pin = '';
  bool _wrongPin = false;

  static const _correctPin = '123456';
  static const _maxLength = 6;

  void _onKey(String key) {
    setState(() {
      _wrongPin = false;
      if (key == '↻') {
        _pin = '';
      } else if (key == 'C') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (_pin.length < _maxLength) {
        _pin += key;
        if (_pin.length == _maxLength) {
          if (_pin == _correctPin) {
            Navigator.of(context).pop(true);
          } else {
            _pin = '';
            _wrongPin = true;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.35,
        vertical: AppSpacing.x4,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key_rounded,
                        color: AppColors.onPrimary, size: 22),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'PIN Supervisor',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Batal',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // PIN display
            ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x6,
                  vertical: AppSpacing.x8,
                ),
                child: Column(
                  children: [
                    if (_wrongPin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                        child: Text(
                          'PIN salah, coba lagi',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_maxLength, (i) {
                        final filled = i < _pin.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.x3),
                          child: filled
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : Container(
                                  width: 28,
                                  height: 2,
                                  color: AppColors.primary,
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Numpad
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                      ['↻', '0', 'C'],
                    ]) ...[
                      Row(
                        children: row.map((key) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: key == row.first ? 0 : AppSpacing.x3,
                                bottom: row == ['↻', '0', 'C']
                                    ? 0
                                    : AppSpacing.x3,
                              ),
                              child: _PinKey(
                                label: key,
                                onTap: () => _onKey(key),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIcon = label == '↻';
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: AspectRatio(
          aspectRatio: 1.6,
          child: Center(
            child: isIcon
                ? const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 26)
                : Text(
                    label,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Zone selector ─────────────────────────────────────────────────────────────

class _ZoneSelector extends StatelessWidget {
  const _ZoneSelector({
    required this.zones,
    required this.selectedIndex,
    required this.onZoneSelected,
  });

  final List<_Zone> zones;
  final int selectedIndex;
  final ValueChanged<int> onZoneSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(zones.length, (index) {
        final isSelected = index == selectedIndex;
        return Expanded(
          child: Material(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
            child: InkWell(
              onTap: () => onZoneSelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
                child: Text(
                  zones[index].name,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
