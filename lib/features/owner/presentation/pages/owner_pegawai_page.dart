import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/pegawai_remote_datasource.dart';
import '../widgets/navigation/owner_drawer.dart';

enum _StaffRole { supervisor, pointOfSale, dapur, gudang }

extension _StaffRoleLabel on _StaffRole {
  String get label {
    switch (this) {
      case _StaffRole.supervisor:
        return 'Supervisor';
      case _StaffRole.pointOfSale:
        return 'Point Of Sale';
      case _StaffRole.dapur:
        return 'Dapur';
      case _StaffRole.gudang:
        return 'Gudang';
    }
  }
}

class _StaffData {
  _StaffData({
    required this.nama,
    required this.idAkses,
    required this.role,
    this.userId,
    this.email = '',
    this.kataSandi = '',
  });

  int? userId;
  String nama;
  String idAkses;
  _StaffRole role;
  String email;
  String kataSandi;
}

class _EditResult {
  const _EditResult.deleted() : deleted = true, staff = null;
  const _EditResult.saved(this.staff)
      : deleted = false;

  final bool deleted;
  final _StaffData? staff;
}

class OwnerPegawaiPage extends StatefulWidget {
  const OwnerPegawaiPage({super.key});

  @override
  State<OwnerPegawaiPage> createState() => _OwnerPegawaiPageState();
}

class _OwnerPegawaiPageState extends State<OwnerPegawaiPage> {
  final _datasource = PegawaiRemoteDatasourceImpl();
  final Map<_StaffRole, List<_StaffData>> _staffByRole = {
    _StaffRole.supervisor: [],
    _StaffRole.pointOfSale: [],
    _StaffRole.dapur: [],
    _StaffRole.gudang: [],
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  static _StaffRole? _roleFromApi(String r) => switch (r) {
        'supervisor' => _StaffRole.supervisor,
        'kasir' => _StaffRole.pointOfSale,
        'dapur' => _StaffRole.dapur,
        'gudang' => _StaffRole.gudang,
        // admin/owner tak ditampilkan di daftar pegawai operasional.
        _ => null,
      };

  static String _roleToApi(_StaffRole r) => switch (r) {
        _StaffRole.supervisor => 'supervisor',
        _StaffRole.pointOfSale => 'kasir',
        _StaffRole.dapur => 'dapur',
        _StaffRole.gudang => 'gudang',
      };

  Future<void> _loadStaff() async {
    setState(() => _loading = true);
    try {
      final users = await _datasource.fetchAll();
      final map = {
        _StaffRole.supervisor: <_StaffData>[],
        _StaffRole.pointOfSale: <_StaffData>[],
        _StaffRole.dapur: <_StaffData>[],
        _StaffRole.gudang: <_StaffData>[],
      };
      for (final u in users) {
        final role = _roleFromApi(u.role);
        if (role == null) continue;
        map[role]!.add(_StaffData(
          userId: u.userId,
          nama: u.namaUser,
          idAkses: u.username,
          role: role,
        ));
      }
      if (!mounted) return;
      setState(() {
        _staffByRole
          ..clear()
          ..addAll(map);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const OwnerDrawer(activePage: OwnerDrawerPage.pegawai),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x4,
                        0,
                        AppSpacing.x4,
                        AppSpacing.x6,
                      ),
                      children: _StaffRole.values
                          .map((role) => _buildRoleSection(context, role))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
              Expanded(
                child: Text(
                  'Pegawai',
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: AppColors.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _AppBarButton(
                label: 'Kehadiran',
                icon: Icons.co_present_rounded,
                filled: true,
                onTap: () => _showKehadiranSheet(context),
              ),
              const SizedBox(width: AppSpacing.x2),
              _AppBarButton(
                label: 'Pengaturan',
                onTap: () => _showPengaturanSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSection(BuildContext context, _StaffRole role) {
    final staff = _staffByRole[role]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.x5),
        Row(
          children: [
            Expanded(
              child: Text(
                role.label,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            _AddIconButton(
              onTap: () => _showTambahSheet(context, preselectedRole: role),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x3),
        ...staff.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x3),
            child: _StaffItem(
              staff: entry.value,
              onTap: () => _showEditSheet(context, role, entry.key),
              onDelete: () => _onDelete(role, entry.key),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onDelete(_StaffRole role, int index) async {
    final id = _staffByRole[role]![index].userId;
    if (id == null) return;
    try {
      await _datasource.delete(id);
      await _loadStaff();
    } catch (_) {
      if (mounted) _snack('Gagal menghapus pegawai');
    }
  }

  Future<void> _showTambahSheet(
    BuildContext context, {
    _StaffRole? preselectedRole,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _TambahStaffSheet(
        preselectedRole: preselectedRole,
        onTambah: (staff) async {
          try {
            await _datasource.create(
              namaUser: staff.nama,
              username: staff.idAkses,
              password: staff.kataSandi,
              role: _roleToApi(staff.role),
            );
            await _loadStaff();
          } catch (_) {
            if (mounted) _snack('Gagal menambah pegawai');
          }
        },
      ),
    );
  }

  Future<void> _showKehadiranSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _KehadiranSheet(),
    );
  }

  Future<void> _showPengaturanSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _PengaturanSheet(),
    );
  }

  Future<void> _showEditSheet(
    BuildContext context,
    _StaffRole role,
    int index,
  ) async {
    final staff = _staffByRole[role]![index];
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _EditStaffSheet(staff: staff),
    );
    if (result == null || !mounted) return;
    final id = staff.userId;
    if (id == null) return;
    try {
      if (result.deleted) {
        await _datasource.delete(id);
      } else {
        final updated = result.staff!;
        await _datasource.update(
          id,
          namaUser: updated.nama,
          username: updated.idAkses,
          role: _roleToApi(updated.role),
          password: updated.kataSandi.isEmpty ? null : updated.kataSandi,
        );
      }
      await _loadStaff();
    } catch (_) {
      if (mounted) _snack('Gagal menyimpan perubahan');
    }
  }
}

// ── AppBar buttons ────────────────────────────────────────────────────────────

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

class _AppBarButton extends StatelessWidget {
  const _AppBarButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.tertiary : Colors.transparent,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sm,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x2,
          ),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: Border.all(color: AppColors.onSecondary),
                  borderRadius: AppRadius.sm,
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.onTertiary, size: 18),
                const SizedBox(width: AppSpacing.x1),
              ],
              Text(
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: filled ? AppColors.onTertiary : AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add icon button ───────────────────────────────────────────────────────────

class _AddIconButton extends StatelessWidget {
  const _AddIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sm,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 22),
        ),
      ),
    );
  }
}

// ── Staff item row ────────────────────────────────────────────────────────────

class _StaffItem extends StatelessWidget {
  const _StaffItem({
    required this.staff,
    required this.onTap,
    required this.onDelete,
  });

  final _StaffData staff;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outline),
                borderRadius: AppRadius.md,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x4,
                ),
                child: Text(
                  '${staff.nama}  -  ${staff.idAkses}',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        GestureDetector(
          onTap: onDelete,
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
            size: 22,
          ),
        ),
      ],
    );
  }
}

// ── Tambah Staff sheet ────────────────────────────────────────────────────────

class _TambahStaffSheet extends StatefulWidget {
  const _TambahStaffSheet({
    required this.onTambah,
    this.preselectedRole,
  });

  final _StaffRole? preselectedRole;
  final ValueChanged<_StaffData> onTambah;

  @override
  State<_TambahStaffSheet> createState() => _TambahStaffSheetState();
}

class _TambahStaffSheetState extends State<_TambahStaffSheet> {
  late _StaffRole _selectedRole;
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _idAksesCtrl = TextEditingController();
  final _kataSandiCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.preselectedRole ?? _StaffRole.supervisor;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _idAksesCtrl.dispose();
    _kataSandiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(title: 'Tambah Staff', onClose: () => Navigator.pop(context)),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SheetField(
                    label: 'Nama Staff',
                    required: true,
                    controller: _namaCtrl,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _SheetField(
                    label: 'Email',
                    required: true,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _RoleSelector(
                    selected: _selectedRole,
                    onChanged: (r) => setState(() => _selectedRole = r),
                    required: true,
                    locked: widget.preselectedRole != null,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _SheetField(
                    label: 'ID Akses',
                    required: true,
                    controller: _idAksesCtrl,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _SheetField(
                    label: 'Kata Sandi',
                    required: true,
                    controller: _kataSandiCtrl,
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          _BottomAction(label: 'Tambah', onTap: _onTambah),
        ],
      ),
    );
  }

  void _onTambah() {
    final nama = _namaCtrl.text.trim();
    final idAkses = _idAksesCtrl.text.trim();
    if (nama.isEmpty || idAkses.isEmpty) return;
    widget.onTambah(
      _StaffData(
        nama: nama,
        idAkses: idAkses,
        role: _selectedRole,
        email: _emailCtrl.text.trim(),
        kataSandi: _kataSandiCtrl.text,
      ),
    );
    Navigator.pop(context);
  }
}

// ── Edit Staff sheet ──────────────────────────────────────────────────────────

class _EditStaffSheet extends StatefulWidget {
  const _EditStaffSheet({required this.staff});

  final _StaffData staff;

  @override
  State<_EditStaffSheet> createState() => _EditStaffSheetState();
}

class _EditStaffSheetState extends State<_EditStaffSheet> {
  late _StaffRole _selectedRole;
  late final TextEditingController _namaCtrl;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.staff.role;
    _namaCtrl = TextEditingController(text: widget.staff.nama);
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(
            title: widget.staff.nama,
            onClose: () => Navigator.pop(context),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SheetField(label: 'Nama Staff', controller: _namaCtrl),
                  const SizedBox(height: AppSpacing.x4),
                  _RoleSelector(
                    selected: _selectedRole,
                    onChanged: (r) => setState(() => _selectedRole = r),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  _HapusButton(onTap: _onHapus),
                ],
              ),
            ),
          ),
          _BottomAction(label: 'Simpan', onTap: _onSimpan),
        ],
      ),
    );
  }

  void _onHapus() {
    Navigator.pop(context, const _EditResult.deleted());
  }

  void _onSimpan() {
    final nama = _namaCtrl.text.trim();
    if (nama.isEmpty) return;
    Navigator.pop(
      context,
      _EditResult.saved(
        _StaffData(
          nama: nama,
          idAkses: widget.staff.idAkses,
          role: _selectedRole,
          email: widget.staff.email,
          kataSandi: widget.staff.kataSandi,
        ),
      ),
    );
  }
}

// ── Shared sheet widgets ──────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          InkWell(
            onTap: onClose,
            borderRadius: AppRadius.full,
            child: const Icon(Icons.close_rounded, size: 24),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.required = false,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
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
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onChanged,
    this.required = false,
    this.locked = false,
  });

  final _StaffRole selected;
  final ValueChanged<_StaffRole> onChanged;
  final bool required;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Role',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        Row(
          children: _StaffRole.values.map((role) {
            final isSelected = role == selected;
            return Expanded(
              child: GestureDetector(
                onTap: locked ? null : () => onChanged(role),
                child: Container(
                  margin: EdgeInsets.only(
                    right: role != _StaffRole.gudang ? AppSpacing.x2 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.x3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : locked
                            ? AppColors.surfaceContainerHighest
                            : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.outline,
                    ),
                    borderRadius: AppRadius.sm,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    role.label,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _HapusButton extends StatelessWidget {
  const _HapusButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadius.sm,
        ),
        alignment: Alignment.center,
        child: Text(
          'Hapus Staff',
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: AppColors.onError,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
        color: Colors.green.shade600,
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Kehadiran sheet ───────────────────────────────────────────────────────────

class _AttendanceRecord {
  const _AttendanceRecord({
    required this.nama,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  final String nama;
  final String tanggal;
  final String jamMasuk;
  final String jamKeluar;
}

class _KehadiranSheet extends StatefulWidget {
  const _KehadiranSheet();

  @override
  State<_KehadiranSheet> createState() => _KehadiranSheetState();
}

class _KehadiranSheetState extends State<_KehadiranSheet> {
  final _searchCtrl = TextEditingController();
  DateTime? _selectedDate;

  final List<_AttendanceRecord> _records = const [
    _AttendanceRecord(
      nama: 'Kasir01',
      tanggal: '14 Agustus 2025',
      jamMasuk: '12:32:02',
      jamKeluar: '18:40:32',
    ),
    _AttendanceRecord(
      nama: 'Dapur01',
      tanggal: '14 Agustus 2025',
      jamMasuk: '12:11:12',
      jamKeluar: '21:08:16',
    ),
    _AttendanceRecord(
      nama: 'Gudang01',
      tanggal: '14 Agustus 2025',
      jamMasuk: '12:11:12',
      jamKeluar: '21:08:16',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(
            title: 'Kehadiran',
            onClose: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
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
                      filled: true,
                      fillColor: AppColors.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.sm,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.sm,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.sm,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.x2),
                const Icon(
                  Icons.filter_list_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.x2),
                Material(
                  color: AppColors.primary,
                  borderRadius: AppRadius.sm,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    borderRadius: AppRadius.sm,
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.x2),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.x2),
                Material(
                  color: AppColors.primary,
                  borderRadius: AppRadius.sm,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur belum tersedia')),
                      );
                    },
                    borderRadius: AppRadius.sm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x2,
                      ),
                      child: Text(
                        'Export Excel',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x2,
              ),
              itemCount: _records.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                color: AppColors.outlineVariant,
              ),
              itemBuilder: (_, i) => _AttendanceRow(record: _records[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record});

  final _AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              record.nama,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              record.tanggal,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TimeBadge(time: record.jamMasuk),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
                child: Text(
                  '-',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              _TimeBadge(time: record.jamKeluar),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.sm,
      ),
      child: Text(
        time,
        style: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

// ── Pengaturan sheet ──────────────────────────────────────────────────────────

class _PengaturanSheet extends StatefulWidget {
  const _PengaturanSheet();

  @override
  State<_PengaturanSheet> createState() => _PengaturanSheetState();
}

class _PengaturanSheetState extends State<_PengaturanSheet> {
  bool _batasiArea = false;
  final _jarakCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _jarakCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(
          title: 'Pengaturan',
          onClose: () => Navigator.pop(context),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outline),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x4,
                      vertical: AppSpacing.x3,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Batasi area absensi di sekitar lokasi toko',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        Switch(
                          value: _batasiArea,
                          onChanged: (v) => setState(() => _batasiArea = v),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_batasiArea) ...[
                  const SizedBox(height: AppSpacing.x4),
                  Text(
                    'Jarak Maksimum',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _jarakCtrl,
                          keyboardType: TextInputType.number,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.x4,
                              vertical: AppSpacing.x3,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.sm,
                              borderSide:
                                  const BorderSide(color: AppColors.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.sm,
                              borderSide:
                                  const BorderSide(color: AppColors.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.sm,
                              borderSide:
                                  const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x2),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outline),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.x4,
                            vertical: AppSpacing.x3,
                          ),
                          child: Text(
                            'Meter',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Text(
                    'Alamat Toko',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  ClipRRect(
                    borderRadius: AppRadius.sm,
                    child: SizedBox(
                      height: 240,
                      child: FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(-7.4558, 112.7183),
                          initialZoom: 13,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.resto_pos',
                          ),
                          const MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(-7.4558, 112.7183),
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.error,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                ],
              ],
            ),
          ),
        ),
        if (_batasiArea)
          _BottomAction(label: 'Simpan', onTap: () => Navigator.pop(context)),
        if (!_batasiArea) const SizedBox(height: AppSpacing.x4),
      ],
    );
  }
}
