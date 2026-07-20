import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/member_remote_datasource.dart';
import '../../data/models/member_model.dart';

// ── Public result type ────────────────────────────────────────────────────────

class SelectedMember {
  const SelectedMember({
    required this.name,
    required this.points,
    this.memberId,
  });
  final String name;
  final int points;

  /// Dipakai agar pesanan tersimpan dengan kaitan member, dan poin bisa
  /// ditukar lewat server.
  final int? memberId;
}

// ── Model tampilan ────────────────────────────────────────────────────────────

class _Member {
  const _Member({
    required this.name,
    required this.phone,
    required this.role,
    this.id,
    this.points = 0,
    this.fullName,
    this.gender,
    this.email,
    this.address,
    this.birthDate,
    this.birthDateIso,
  });

  /// Id dari server; null hanya untuk member yang belum tersimpan.
  final int? id;
  final String name;
  final String phone;
  final String role;
  final int points;
  final String? fullName;
  final String? gender;
  final String? email;
  final String? address;

  /// Tanggal lahir untuk ditampilkan (mis. "20 Apr 1992").
  final String? birthDate;

  /// Tanggal lahir format YYYY-MM-DD untuk dikirim ke server.
  final String? birthDateIso;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class _MemberTransaction {
  const _MemberTransaction({
    required this.code,
    required this.items,
    required this.date,
    required this.time,
    required this.total,
    required this.paymentMethod,
    required this.customerName,
  });
  final String code;
  final String items;
  final String date;
  final String time;
  final String total;
  final String paymentMethod;
  final String customerName;
}

// Cache daftar member selama sesi; diisi dari GET /member.
final List<_Member> _membersList = [];

/// Menyimpan perubahan poin member ke server (`POST /member/:id/poin`).
///
/// Sebelumnya poin hanya diubah di list dalam memori sehingga hilang saat
/// aplikasi ditutup. Selisih terhadap poin lama dikirim sebagai `earn` atau
/// `redeem` agar server ikut mencatat riwayat poinnya.
Future<void> updateMemberPoints(String name, int newPoints) async {
  final idx = _membersList.indexWhere((m) => m.name == name);
  if (idx < 0) return;
  final m = _membersList[idx];
  final selisih = newPoints - m.points;
  if (selisih == 0 || m.id == null) return;

  try {
    await MemberRemoteDatasourceImpl().adjustPoin(
      memberId: m.id!,
      tipe: selisih > 0 ? 'earn' : 'redeem',
      poin: selisih.abs(),
    );
  } on ApiException {
    // Poin gagal disimpan; biarkan nilai lama agar tampilan tidak berbohong.
    return;
  }

  _membersList[idx] = _Member(
    id: m.id,
    name: m.name,
    phone: m.phone,
    role: m.role,
    points: newPoints,
    fullName: m.fullName,
    gender: m.gender,
    email: m.email,
    address: m.address,
    birthDate: m.birthDate,
    birthDateIso: m.birthDateIso,
  );
}

// ── Page ──────────────────────────────────────────────────────────────────────

class PilihMemberPage extends StatefulWidget {
  const PilihMemberPage({super.key});

  @override
  State<PilihMemberPage> createState() => _PilihMemberPageState();
}

class _PilihMemberPageState extends State<PilihMemberPage> {
  final _searchCtrl = TextEditingController();
  final _datasource = MemberRemoteDatasourceImpl();
  late List<_Member> _filtered = List.of(_membersList);
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _load();
  }

  /// Memuat daftar member dari backend (GET /member) ke list halaman.
  Future<void> _load() async {
    try {
      final models = await _datasource.fetchMembers();
      if (!mounted) return;
      _membersList
        ..clear()
        ..addAll(models.map((m) => _Member(
              id: m.memberId,
              name: m.nama,
              phone: m.noTelp ?? '',
              role: 'Guest',
              points: m.poin,
              email: m.email,
              gender: m.gender,
              address: m.alamat,
              birthDate: _formatTanggalLahir(m.tanggalLahir),
              birthDateIso: m.tanggalLahir,
            )));
      setState(() {
        _filtered = List.of(_membersList);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat member.';
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isSearching = false;

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.of(_membersList)
          : _membersList
              .where((m) =>
                  m.name.toLowerCase().contains(q) ||
                  m.phone.contains(q))
              .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchCtrl.clear();
    });
  }

  /// Ubah "1990-06-15" menjadi "15 Jun 1990" untuk ditampilkan.
  static String? _formatTanggalLahir(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final d = DateTime.tryParse(iso);
    if (d == null) return null;
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  void _onAdd() {
    Navigator.push<_Member>(
      context,
      MaterialPageRoute(builder: (_) => const _AddMemberPage()),
    ).then((member) async {
      if (member == null || !mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await _datasource.createMember(
          nama: member.name,
          noTelp: member.phone,
          email: member.email,
          gender: member.gender,
          tanggalLahir: member.birthDateIso,
          alamat: member.address,
        );
      } on ApiException catch (e) {
        if (mounted) messenger.showSnackBar(SnackBar(content: Text(e.message)));
        return;
      }
      // Muat ulang dari server agar id member baru ikut terbawa.
      await _load();
      if (mounted) _searchCtrl.clear();
    });
  }

  Future<void> _onHapusMember(_Member member) async {
    if (member.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _datasource.deleteMember(member.id!);
    } on ApiException catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    await _load();
  }

  void _onUbahMember(_Member original) {
    Navigator.push<_Member>(
      context,
      MaterialPageRoute(
        builder: (_) => _AddMemberPage(initialMember: original),
      ),
    ).then((updated) async {
      if (updated == null || !mounted || original.id == null) return;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await _datasource.updateMember(
          memberId: original.id!,
          nama: updated.name,
          noTelp: updated.phone,
          email: updated.email,
          gender: updated.gender,
          tanggalLahir: updated.birthDateIso,
          alamat: updated.address,
        );
      } on ApiException catch (e) {
        if (mounted) messenger.showSnackBar(SnackBar(content: Text(e.message)));
        return;
      }
      await _load();
    });
  }

  Future<void> _onMemberSelected(_Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _PilihPelangganDialog(),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(
        SelectedMember(
          name: member.name,
          points: member.points,
          memberId: member.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _MemberHeader(
              searchCtrl: _searchCtrl,
              onAdd: _onAdd,
              onClose: () => Navigator.of(context).pop(),
              isSearching: _isSearching,
              onSearchToggle: _toggleSearch,
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada member',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final member = _filtered[index];
                        return _MemberTile(
                          member: member,
                          onSelected: (m) => _onMemberSelected(m),
                          onLihat: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _MemberDetailPage(member: member),
                            ),
                          ),
                          onUbah: () => _onUbahMember(member),
                          onHapus: () => _onHapusMember(member),
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

// ── Header ────────────────────────────────────────────────────────────────────

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({
    required this.searchCtrl,
    required this.onAdd,
    required this.onClose,
    required this.isSearching,
    required this.onSearchToggle,
  });

  final TextEditingController searchCtrl;
  final VoidCallback onAdd;
  final VoidCallback onClose;
  final bool isSearching;
  final VoidCallback onSearchToggle;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x2,
        ),
        child: isSearching
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: 'Cari member...',
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.search, color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _HeaderIconButton(icon: Icons.close, onTap: onSearchToggle),
                ],
              )
            : Row(
                children: [
                  _HeaderIconButton(icon: Icons.add, onTap: onAdd),
                  const SizedBox(width: AppSpacing.x2),
                  _HeaderIconButton(icon: Icons.search, onTap: onSearchToggle),
                  const Spacer(),
                  _HeaderIconButton(icon: Icons.close, onTap: onClose),
                ],
              ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ── Member tile ───────────────────────────────────────────────────────────────

enum _MemberAction { lihat, ubah, hapus }

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.onSelected,
    required this.onLihat,
    required this.onUbah,
    required this.onHapus,
  });

  final _Member member;
  final ValueChanged<_Member> onSelected;
  final VoidCallback onLihat;
  final VoidCallback onUbah;
  final VoidCallback onHapus;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(member),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            _Avatar(initial: member.initial),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.phone,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.role,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _MoreButton(member: member, onLihat: onLihat, onUbah: onUbah, onHapus: onHapus),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({
    required this.member,
    required this.onLihat,
    required this.onUbah,
    required this.onHapus,
  });

  final _Member member;
  final VoidCallback onLihat;
  final VoidCallback onUbah;
  final VoidCallback onHapus;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MemberAction>(
      onSelected: (action) => _onAction(context, action),
      itemBuilder: (_) => const [
        PopupMenuItem(value: _MemberAction.lihat, child: Text('Lihat')),
        PopupMenuItem(value: _MemberAction.ubah, child: Text('Ubah')),
        PopupMenuItem(value: _MemberAction.hapus, child: Text('Hapus')),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: const Icon(
          Icons.more_horiz,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }

  void _onAction(BuildContext context, _MemberAction action) {
    if (action == _MemberAction.lihat) onLihat();
    if (action == _MemberAction.ubah) onUbah();
    if (action == _MemberAction.hapus) onHapus();
  }
}

// ── Member detail page ────────────────────────────────────────────────────────

class _MemberDetailPage extends StatefulWidget {
  const _MemberDetailPage({required this.member});

  final _Member member;

  @override
  State<_MemberDetailPage> createState() => __MemberDetailPageState();
}

class __MemberDetailPageState extends State<_MemberDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _DetailTabBar(
              tabCtrl: _tabCtrl,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _ProfilTab(member: widget.member),
                  _RiwayatTab(member: widget.member),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTabBar extends StatelessWidget {
  const _DetailTabBar({required this.tabCtrl, required this.onClose});

  final TabController tabCtrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabCtrl,
      builder: (context, _) {
        return Row(
          children: [
            _DetailTab(
              label: 'PROFIL',
              isActive: tabCtrl.index == 0,
              onTap: () => tabCtrl.animateTo(0),
            ),
            _DetailTab(
              label: 'RIWAYAT',
              isActive: tabCtrl.index == 1,
              onTap: () => tabCtrl.animateTo(1),
            ),
            Material(
              color: AppColors.onPrimaryContainer,
              child: InkWell(
                onTap: onClose,
                child: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailTab extends StatelessWidget {
  const _DetailTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isActive ? AppColors.primary : AppColors.onPrimaryContainer,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                label,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Profil tab ────────────────────────────────────────────────────────────────

class _ProfilTab extends StatelessWidget {
  const _ProfilTab({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gold hero section
          ColoredBox(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x6),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        member.initial,
                        style: AppTypography.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  Text(
                    member.name,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Detail fields
          const SizedBox(height: AppSpacing.x4),
          _DetailField(label: 'Tipe Pelanggan', value: member.role),
          _DetailField(label: 'Nama', value: member.fullName),
          _DetailField(label: 'Gender', value: member.gender),
          _DetailField(label: 'Email', value: member.email),
          _DetailField(label: 'Telpon', value: member.phone),
          _DetailField(label: 'Alamat', value: member.address),
          _DetailField(label: 'Tanggal Lahir', value: member.birthDate),
          const SizedBox(height: AppSpacing.x4),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x4,
        0,
        AppSpacing.x4,
        AppSpacing.x5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value ?? '-',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Riwayat tab ───────────────────────────────────────────────────────────────

class _RiwayatTab extends StatefulWidget {
  const _RiwayatTab({required this.member});

  final _Member member;

  @override
  State<_RiwayatTab> createState() => _RiwayatTabState();
}

class _RiwayatTabState extends State<_RiwayatTab> {
  static const _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  final _datasource = MemberRemoteDatasourceImpl();
  List<_MemberTransaction> _transactions = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Riwayat diambil dari `GET /member/:id/transaksi`, menggantikan data
  /// contoh yang sebelumnya di-hardcode per nama member.
  Future<void> _load() async {
    final id = widget.member.id;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final rows = await _datasource.fetchTransaksiMember(id);
      if (!mounted) return;
      setState(() {
        _transactions = rows.map(_toView).toList();
        _loading = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  static String _ribuan(double v) {
    final s = v.round().abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String _duaDigit(int v) => v.toString().padLeft(2, '0');

  _MemberTransaction _toView(MemberTransaksiModel m) {
    final w = m.waktu.toLocal();
    return _MemberTransaction(
      code: m.kodeTransaksi,
      items: m.items,
      date: '${w.day} ${_namaBulan[w.month - 1]} ${w.year}',
      time: '${_duaDigit(w.hour)}:${_duaDigit(w.minute)}',
      total: _ribuan(m.total),
      paymentMethod: m.tipePembayaran,
      customerName: m.namaKontak,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _transactions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x4,
            ),
            child: Text(
              'PESANAN',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : transactions.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada riwayat pesanan',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) =>
                      _TransactionItem(tx: transactions[index]),
                ),
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.tx});

  final _MemberTransaction tx;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💵', style: TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.code,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.items,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.date}  ${tx.time}  ${tx.total}  ${tx.paymentMethod}  (${tx.customerName})',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pilih pelanggan confirmation dialog ───────────────────────────────────────

class _PilihPelangganDialog extends StatelessWidget {
  const _PilihPelangganDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Pilih Pelanggan',
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Lanjut tambahkan pelanggan ke pesanan ini?',
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'BATAL',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'KONFIRMASI',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Add member page ───────────────────────────────────────────────────────────

const _tipeOptions = ['Guest'];

class _AddMemberPage extends StatefulWidget {
  const _AddMemberPage({this.initialMember});

  final _Member? initialMember;

  @override
  State<_AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<_AddMemberPage> {
  late String _selectedTipe;
  late String _selectedGender;
  late DateTime _birthDate;

  late final TextEditingController _namaCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telponCtrl;
  late final TextEditingController _alamatCtrl;
  late final TextEditingController _catatanCtrl;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMember;
    _selectedTipe = m?.role ?? 'Guest';
    _selectedGender = m?.gender ?? 'Male';
    _birthDate = _parseBirthDate(m?.birthDate) ?? DateTime(1900);
    _namaCtrl = TextEditingController(text: m?.name ?? '');
    _emailCtrl = TextEditingController(text: m?.email ?? '');
    _telponCtrl = TextEditingController(text: m?.phone ?? '');
    _alamatCtrl = TextEditingController(text: m?.address ?? '');
    _catatanCtrl = TextEditingController();
  }

  DateTime? _parseBirthDate(String? s) {
    if (s == null) return null;
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final p = s.split(' ');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = mo.indexOf(p[1]) + 1;
    final y = int.tryParse(p[2]);
    if (d == null || m == 0 || y == null) return null;
    return DateTime(y, m, d);
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _telponCtrl.dispose();
    _alamatCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${_birthDate.day.toString().padLeft(2, '0')} '
        '${months[_birthDate.month - 1]} ${_birthDate.year}';
  }

  Future<void> _pickTipe() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _TipeKategoriDialog(
        options: _tipeOptions,
        selected: _selectedTipe,
      ),
    );
    if (result != null) setState(() => _selectedTipe = result);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: AppColors.scheme),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            ColoredBox(
              color: Colors.grey.shade700,
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const SizedBox(width: 52),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.initialMember != null
                              ? 'Ubah Contact'
                              : 'Membuat Contact Baru',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(Icons.close, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x6,
                  vertical: AppSpacing.x6,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _OutlinedPickerField(
                          label: 'Tipe Pelanggan',
                          value: _selectedTipe,
                          onTap: _pickTipe,
                        ),
                        const SizedBox(height: AppSpacing.x5),
                        _AddFormField(label: 'Nama *', controller: _namaCtrl),
                        const SizedBox(height: AppSpacing.x5),
                        _GenderSelector(
                          selected: _selectedGender,
                          onChanged: (g) => setState(() => _selectedGender = g),
                        ),
                        const SizedBox(height: AppSpacing.x5),
                        _AddFormField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: AppSpacing.x5),
                        _AddFormField(label: 'Telpon *', controller: _telponCtrl, keyboardType: TextInputType.phone),
                        const SizedBox(height: AppSpacing.x5),
                        _AddFormField(label: 'Alamat', controller: _alamatCtrl),
                        const SizedBox(height: AppSpacing.x5),
                        _OutlinedPickerField(
                          label: 'Tanggal Lahir',
                          value: _formattedDate,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: AppSpacing.x5),
                        _AddFormField(label: 'Catatan', controller: _catatanCtrl),
                        const SizedBox(height: AppSpacing.x4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Material(
        color: AppColors.primary,
        child: InkWell(
          onTap: () {
            final name = _namaCtrl.text.trim();
            final phone = _telponCtrl.text.trim();
            if (name.isEmpty || phone.isEmpty) return;
            Navigator.of(context).pop(
              _Member(
                name: name,
                phone: phone,
                role: _selectedTipe,
                fullName: name,
                gender: _selectedGender,
                email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
                address: _alamatCtrl.text.trim().isEmpty ? null : _alamatCtrl.text.trim(),
                birthDate: _formattedDate,
                // Bentuk ISO untuk dikirim ke server (kolom date).
                birthDateIso: _birthDate.year <= 1900
                    ? null
                    : _birthDate.toIso8601String().substring(0, 10),
              ),
            );
          },
          child: SizedBox(
            height: 56,
            child: Center(
              child: Text(
                'SIMPAN',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedPickerField extends StatelessWidget {
  const _OutlinedPickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x3,
            vertical: AppSpacing.x3,
          ),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AddFormField extends StatelessWidget {
  const _AddFormField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender *',
          style: const TextStyle(color: AppColors.primary, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.x2),
        Row(
          children: [
            Expanded(
              child: _GenderButton(
                label: 'Male',
                isSelected: selected == 'Male',
                onTap: () => onChanged('Male'),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: _GenderButton(
                label: 'Female',
                isSelected: selected == 'Female',
                onTap: () => onChanged('Female'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tipe kategori dialog ──────────────────────────────────────────────────────

class _TipeKategoriDialog extends StatelessWidget {
  const _TipeKategoriDialog({
    required this.options,
    required this.selected,
  });

  final List<String> options;
  final String selected;

  static const _itemColor = Color(0xFF8E7210);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.25,
        vertical: AppSpacing.x4,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
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
                    Expanded(
                      child: Text(
                        'Tipe Kategori',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            // Items + empty space
            Expanded(
              child: ColoredBox(
                color: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...options.map(
                      (opt) => Material(
                        color: _itemColor,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(opt),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.x4,
                              vertical: AppSpacing.x4,
                            ),
                            child: Text(
                              opt == selected ? '[$opt]' : opt,
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
