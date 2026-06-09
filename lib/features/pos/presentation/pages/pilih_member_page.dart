import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

// ── Public result type ────────────────────────────────────────────────────────

class SelectedMember {
  const SelectedMember({required this.name, required this.points});
  final String name;
  final int points;
}

// ── Mock data ─────────────────────────────────────────────────────────────────

class _Member {
  const _Member({
    required this.name,
    required this.phone,
    required this.role,
    this.points = 0,
    this.fullName,
    this.gender,
    this.email,
    this.address,
    this.birthDate,
  });
  final String name;
  final String phone;
  final String role;
  final int points;
  final String? fullName;
  final String? gender;
  final String? email;
  final String? address;
  final String? birthDate;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class _MockTransaction {
  const _MockTransaction({
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

const _seedMembers = [
  _Member(
    name: 'Owner 01',
    phone: '+6282275641556',
    role: 'Guest',
    points: 50,
    fullName: 'Anggun',
    gender: 'Female',
    birthDate: '20 Apr 1992',
  ),
];

final _mockTransactionsByMember = <String, List<_MockTransaction>>{
  'Owner 01': [
    _MockTransaction(
      code: '[KODE TRANSAKSI]',
      items: '5x Bakmi Udang, 2x Lemon Squash, 4x Americano',
      date: '24 April 2026',
      time: '16:43',
      total: '237.120',
      paymentMethod: 'TUNAI',
      customerName: 'Owner 01',
    ),
  ],
};

// ── Page ──────────────────────────────────────────────────────────────────────

class PilihMemberPage extends StatefulWidget {
  const PilihMemberPage({super.key});

  @override
  State<PilihMemberPage> createState() => _PilihMemberPageState();
}

class _PilihMemberPageState extends State<PilihMemberPage> {
  final _searchCtrl = TextEditingController();
  final List<_Member> _members = List.of(_seedMembers);
  List<_Member> _filtered = List.of(_seedMembers);

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _members
          .where((m) =>
              m.name.toLowerCase().contains(q) ||
              m.phone.contains(q))
          .toList();
    });
  }

  void _onAdd() {
    // TODO: implement add member
  }

  Future<void> _onMemberSelected(_Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _PilihPelangganDialog(),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(
        SelectedMember(name: member.name, points: member.points),
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
            ),
            Expanded(
              child: _filtered.isEmpty
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
  });

  final TextEditingController searchCtrl;
  final VoidCallback onAdd;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            _HeaderIconButton(
              icon: Icons.add,
              onTap: onAdd,
            ),
            const SizedBox(width: AppSpacing.x2),
            _HeaderIconButton(
              icon: Icons.search,
              onTap: () {},
            ),
            const Spacer(),
            _HeaderIconButton(
              icon: Icons.close,
              onTap: onClose,
            ),
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
  });

  final _Member member;
  final ValueChanged<_Member> onSelected;
  final VoidCallback onLihat;

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
            _MoreButton(member: member, onLihat: onLihat),
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
  const _MoreButton({required this.member, required this.onLihat});

  final _Member member;
  final VoidCallback onLihat;

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
    // TODO: ubah, hapus
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

class _RiwayatTab extends StatelessWidget {
  const _RiwayatTab({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    final transactions = _mockTransactionsByMember[member.name] ?? [];
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
          child: transactions.isEmpty
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

  final _MockTransaction tx;

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
