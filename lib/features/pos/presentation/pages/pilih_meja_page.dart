import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/checkout_remote_datasource.dart';
import '../../data/datasources/meja_remote_datasource.dart';
import '../providers/order_provider.dart';
import '../widgets/shared/pin_supervisor_dialog.dart';

// ── Public result type ──────────────────────────────────────────────────────
// Dikembalikan ke pemanggil saat sebuah meja dipilih untuk pesanan.
class SelectedMeja {
  const SelectedMeja({required this.mejaId, required this.nomor});
  final int mejaId;
  final String nomor;
}

// ── Mock data ─────────────────────────────────────────────────────────────────

enum _MejaStatus { free, occupied, reserved, blocked }

// Result returned by _MejaOptionsDialog to tell the page which action to take.
enum _MejaAction { pilih, reservasi, blokir }

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

  _Meja copyWith({_MejaStatus? status, int? transactionCount}) => _Meja(
        id: id,
        name: name,
        status: status ?? this.status,
        transactionCount: transactionCount ?? this.transactionCount,
        zoneId: zoneId,
      );
}

const _kTanpaZona = 'Tanpa Zona';

/// Memetakan `meja.status` dari backend ke status lokal halaman.
/// Backend tidak punya status `blocked` — itu hanya aksi lokal di FE.
_MejaStatus _mapMejaStatus(String s) => switch (s) {
      'occupied' => _MejaStatus.occupied,
      'reserved' => _MejaStatus.reserved,
      _ => _MejaStatus.free,
    };

// ── Mock transaction data ─────────────────────────────────────────────────────

class _MockItem {
  const _MockItem({required this.name, required this.price, required this.qty});
  final String name;
  final int price;
  final int qty;
  int get total => price * qty;
}

class _MockTransaksi {
  const _MockTransaksi({required this.code, required this.items});
  final String code;
  final List<_MockItem> items;
  int get jumlahItem => items.fold(0, (s, i) => s + i.qty);
  int get subtotal => items.fold(0, (s, i) => s + i.total);
  int get pajak => (subtotal * 0.02).round();
  int get biayaLayanan => (subtotal * 0.02).round();
  int get grandTotal => subtotal + pajak + biayaLayanan;
}

String _fmtNum(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

final _mockTransaksiByMeja = <String, List<_MockTransaksi>>{
  'lesehan01': [
    _MockTransaksi(code: 'Kode Transaksi 001', items: [
      _MockItem(name: 'Bakmi Udang', price: 32000, qty: 1),
      _MockItem(name: 'Americano', price: 10000, qty: 2),
    ]),
    _MockTransaksi(code: 'Kode Transaksi 002', items: [
      _MockItem(name: 'Bakmi Udang', price: 20000, qty: 2),
    ]),
  ],
  'out-01': [
    _MockTransaksi(code: 'Kode Transaksi 001', items: [
      _MockItem(name: 'Nasi Goreng', price: 25000, qty: 2),
      _MockItem(name: 'Es Teh', price: 5000, qty: 3),
    ]),
  ],
};

const _mockJumlahTamuByMeja = <String, int>{
  'lesehan01': 4,
  'out-01': 2,
};

// ── Page ──────────────────────────────────────────────────────────────────────

class PilihMejaPage extends StatefulWidget {
  const PilihMejaPage({super.key});

  @override
  State<PilihMejaPage> createState() => _PilihMejaPageState();
}

class _PilihMejaPageState extends State<PilihMejaPage> {
  final _datasource = MejaRemoteDatasourceImpl();
  final _checkoutDatasource = CheckoutRemoteDatasourceImpl();

  int _tabIndex = 0;
  int _zoneIndex = 0;
  _Meja? _selectedMeja;
  bool _isGantiMejaMode = false;
  List<_Meja> _tables = [];
  List<_Zone> _zones = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Memuat meja dari backend (GET /meja); zona tab dibangun dari nilai `zona`.
  Future<void> _load() async {
    try {
      final models = await _datasource.fetchMeja();
      if (!mounted) return;
      final zonaNames = <String>{for (final m in models) m.zona ?? _kTanpaZona};
      setState(() {
        _zones = zonaNames.map((z) => _Zone(id: z, name: z)).toList();
        _tables = models
            .map((m) => _Meja(
                  id: m.mejaId.toString(),
                  name: m.nomor,
                  status: _mapMejaStatus(m.status),
                  zoneId: m.zona ?? _kTanpaZona,
                ))
            .toList();
        if (_zoneIndex >= _zones.length) _zoneIndex = 0;
        _loading = false;
      });
      _loadTransactionCounts();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat meja.';
      });
    }
  }

  /// Isi jumlah pesanan aktif per meja (badge "N Transaksi Meja") DAN samakan
  /// warna meja dengan kenyataan: merah (occupied) hanya bila ada order aktif.
  /// Status manual (reserved/blokir) tetap dihormati.
  Future<void> _loadTransactionCounts() async {
    try {
      final counts = await _checkoutDatasource.fetchPendingCountByMeja();
      if (!mounted) return;
      setState(() {
        _tables = _tables.map((t) {
          final count = counts[int.tryParse(t.id)] ?? 0;
          var status = t.status;
          if (count > 0) {
            // Ada order aktif → terisi (kecuali sedang reserved/blokir).
            if (status == _MejaStatus.free) status = _MejaStatus.occupied;
          } else if (status == _MejaStatus.occupied) {
            // Tidak ada order aktif tapi masih ditandai terisi → bebaskan.
            status = _MejaStatus.free;
          }
          return t.copyWith(transactionCount: count, status: status);
        }).toList();
      });
    } catch (_) {
      // Non-kritis: badge transaksi gagal dimuat — biarkan default.
    }
  }

  List<_Meja> get _filteredTables => _zones.isEmpty
      ? const []
      : _tables.where((m) => m.zoneId == _zones[_zoneIndex].id).toList();

  String _apiStatus(_MejaStatus s) => switch (s) {
        _MejaStatus.free => 'available',
        _MejaStatus.occupied => 'occupied',
        _MejaStatus.reserved => 'reserved',
        _MejaStatus.blocked => 'blocked',
      };

  void _updateTableStatus(String id, _MejaStatus status) {
    // Update lokal dulu (optimistic), lalu persist ke backend.
    setState(() {
      _tables = _tables
          .map((t) => t.id == id ? t.copyWith(status: status) : t)
          .toList();
    });
    _persistStatus(id, status);
  }

  /// Simpan perubahan status meja ke backend (PATCH /meja/:id/status).
  Future<void> _persistStatus(String id, _MejaStatus status) async {
    final mejaId = int.tryParse(id);
    if (mejaId == null) return; // id non-numerik (data lama/mock) — abaikan
    try {
      await _datasource.updateStatus(mejaId, _apiStatus(status));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan status meja ke server')),
      );
    }
  }

  /// Hasil pilih meja untuk dikembalikan ke pemanggil (ditaut ke pesanan).
  SelectedMeja? _selectedResult(_Meja meja) {
    final id = int.tryParse(meja.id);
    return id == null ? null : SelectedMeja(mejaId: id, nomor: meja.name);
  }

  /// "Lihat Pesanan": muat pesanan pending milik meja ke POS, lalu kembali ke
  /// halaman POS agar kasir bisa membayar.
  Future<void> _onLihatPesanan() async {
    final meja = _selectedMeja;
    if (meja == null) return;
    final mejaId = int.tryParse(meja.id);
    if (mejaId == null) return;
    try {
      final loaded = await _checkoutDatasource.fetchActivePesananForMeja(mejaId);
      if (!mounted) return;
      if (loaded == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum ada pesanan aktif di meja ini')),
        );
        return;
      }
      context.read<OrderProvider>().loadExistingOrder(loaded);
      Navigator.of(context).pop(); // kembali ke POS dengan pesanan termuat
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat pesanan meja')),
      );
    }
  }

  Future<void> _onTableTap(_Meja meja) async {
    if (_isGantiMejaMode) {
      if (meja.status != _MejaStatus.free) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => _GantiMejaConfirmDialog(mejaNama: meja.name),
      );
      if (!mounted) return;
      if (confirmed != true || _selectedMeja == null) return;

      final messenger = ScaffoldMessenger.of(context);
      final oldMejaId = int.tryParse(_selectedMeja!.id);
      final newMejaId = int.tryParse(meja.id);
      if (oldMejaId == null || newMejaId == null) return;

      try {
        // Pindahkan pesanan aktif dari meja lama ke meja baru di backend.
        final loaded =
            await _checkoutDatasource.fetchActivePesananForMeja(oldMejaId);
        if (loaded == null) {
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Tidak ada pesanan aktif di meja ini'),
            ),
          );
          return;
        }
        await _checkoutDatasource.pindahMeja(
          pesananId: loaded.pesananId,
          mejaId: newMejaId,
        );
      } catch (_) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Gagal pindah meja')),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _isGantiMejaMode = false;
        _tabIndex = 1;
      });
      // Muat ulang dari backend: meja tujuan occupied, meja asal available.
      await _load();
      await _loadTransactionCounts();
      if (!mounted) return;
      final moved = _tables.where((t) => t.id == meja.id).toList();
      if (moved.isNotEmpty) setState(() => _selectedMeja = moved.first);
      messenger.showSnackBar(
        SnackBar(content: Text('Pesanan dipindahkan ke meja ${meja.name}')),
      );
      return;
    }

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
          Navigator.of(context).pop(_selectedResult(meja));
        } else if (action == _ReservasiAction.batalkan) {
          _updateTableStatus(meja.id, _MejaStatus.free);
        }

      case _MejaStatus.blocked:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => const _BukaBlokirDialog(),
        );
        if (!mounted) return;
        if (confirmed == true) {
          final pin = await showDialog<String>(
            context: context,
            builder: (_) => const PinSupervisorDialog(),
          );
          if (!mounted) return;
          if (pin != null) {
            _updateTableStatus(meja.id, _MejaStatus.free);
          }
        }

      case _MejaStatus.free:
        final action = await showDialog<_MejaAction>(
          context: context,
          builder: (_) => _MejaOptionsDialog(meja: meja),
        );
        if (!mounted) return;
        if (action == _MejaAction.pilih) {
          // Meja dipilih untuk pesanan → tandai terisi + simpan ke backend.
          _persistStatus(meja.id, _MejaStatus.occupied);
          Navigator.of(context).pop(_selectedResult(meja));
        } else if (action == _MejaAction.reservasi) {
          _updateTableStatus(meja.id, _MejaStatus.reserved);
        } else if (action == _MejaAction.blokir) {
          _updateTableStatus(meja.id, _MejaStatus.blocked);
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
              overrideTitle: _isGantiMejaMode ? 'GANTI MEJA' : null,
              onClose: _isGantiMejaMode
                  ? () => setState(() {
                        _isGantiMejaMode = false;
                        _tabIndex = 1;
                      })
                  : () => Navigator.of(context).pop(),
              onSortTap: () async {
                final index = await showDialog<int>(
                  context: context,
                  builder: (_) => _PilihAreaDialog(
                    zones: _zones,
                    selectedIndex: _zoneIndex,
                  ),
                );
                if (!mounted) return;
                if (index != null) {
                  setState(() {
                    _zoneIndex = index;
                    _tabIndex = 0;
                    _selectedMeja = null;
                  });
                }
              },
            ),
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
                  : _tabIndex == 0
                  ? _TableGrid(
                      tables: _filteredTables,
                      onTableTap: _onTableTap,
                    )
                  : _TransaksiMejaContent(
                      meja: _selectedMeja,
                      onKosongkanMeja: () {
                        final meja = _selectedMeja;
                        if (meja == null) return;
                        // Tidak boleh dikosongkan paksa selama masih ada pesanan
                        // aktif (belum dibayar). Meja bebas otomatis setelah
                        // pembayaran ("Lihat Transaksi"), atau dipindah via
                        // "Ganti Meja".
                        if (meja.transactionCount > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Meja masih punya pesanan aktif. Selesaikan '
                                'pembayaran lewat "Lihat Transaksi" dulu, atau '
                                'pindahkan via "Ganti Meja".',
                              ),
                            ),
                          );
                          return;
                        }
                        _updateTableStatus(meja.id, _MejaStatus.free);
                        setState(() {
                          _selectedMeja = null;
                          _tabIndex = 0;
                        });
                      },
                      onGantiMeja: () => setState(() {
                        _isGantiMejaMode = true;
                        _tabIndex = 0;
                      }),
                      onLihatTransaksi: _onLihatPesanan,
                    ),
            ),
            if (_tabIndex == 0)
              _ZoneSelector(
                zones: _zones,
                selectedIndex: _zoneIndex,
                onZoneSelected: (i) => setState(() {
                  _zoneIndex = i;
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
    required this.onSortTap,
    this.overrideTitle,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onClose;
  final VoidCallback onSortTap;
  final String? overrideTitle;

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
                onTap: onSortTap,
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
            child: overrideTitle != null
                ? Center(
                    child: Text(
                      overrideTitle!,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.onSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : _HeaderTabBar(
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
      _MejaStatus.blocked => Colors.black,
      _MejaStatus.free => AppColors.primary,
    };

    final subtitle = switch (meja.status) {
      _MejaStatus.occupied => '${meja.transactionCount} Transaksi Meja',
      _MejaStatus.reserved => 'Reservasi Meja',
      _MejaStatus.blocked => 'Blokir Meja',
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
  const _TransaksiMejaContent({
    this.meja,
    this.onKosongkanMeja,
    this.onGantiMeja,
    this.onLihatTransaksi,
  });

  final _Meja? meja;
  final VoidCallback? onKosongkanMeja;
  final VoidCallback? onGantiMeja;
  final VoidCallback? onLihatTransaksi;

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
                      onTap: onKosongkanMeja ?? () {},
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    _TransaksiActionButton(
                      label: 'Ganti Meja',
                      color: const Color(0xFF4361EE),
                      icon: Icons.swap_horiz_rounded,
                      onTap: onGantiMeja ?? () {},
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    _TransaksiActionButton(
                      label: 'Lihat Transaksi',
                      color: AppColors.onPrimaryContainer,
                      onTap: onLihatTransaksi ?? () {},
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
                    onTap: () => Navigator.of(context).pop(_MejaAction.blokir),
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
                  final pin = await showDialog<String>(
                    context: context,
                    builder: (_) => const PinSupervisorDialog(),
                  );
                  if (pin != null && context.mounted) {
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

// ── Buka blokir dialog ────────────────────────────────────────────────────────

class _BukaBlokirDialog extends StatelessWidget {
  const _BukaBlokirDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x6,
                AppSpacing.x3,
                AppSpacing.x3,
                AppSpacing.x6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.report_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Text(
                    'Buka Blokir Meja',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    'Apakah anda ingin membuka blokir meja ini?',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.grey.shade300,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.x4,
                        ),
                        child: Text(
                          'Tidak',
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: AppColors.primary,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.x4,
                        ),
                        child: Text(
                          'Ya',
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pilih area dialog ─────────────────────────────────────────────────────────

class _PilihAreaDialog extends StatelessWidget {
  const _PilihAreaDialog({
    required this.zones,
    required this.selectedIndex,
  });

  final List<_Zone> zones;
  final int selectedIndex;

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
                    const Icon(
                      Icons.sort_rounded,
                      color: AppColors.onPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'PILIH AREA',
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
            // Zone list
            ColoredBox(
              color: _bodyColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(zones.length, (index) {
                  final isSelected = index == selectedIndex;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x4,
                        vertical: AppSpacing.x4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              zones[index].name,
                              style: AppTypography.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lihat transaksi dialog ────────────────────────────────────────────────────

class _LihatTransaksiDialog extends StatelessWidget {
  const _LihatTransaksiDialog({required this.meja});

  final _Meja meja;

  List<_MockTransaksi> get _transaksiList =>
      _mockTransaksiByMeja[meja.id] ?? [];
  int get _jumlahTamu => _mockJumlahTamuByMeja[meja.id] ?? 0;
  int get _grandTotal =>
      _transaksiList.fold(0, (s, t) => s + t.grandTotal);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.22,
        vertical: AppSpacing.x8,
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
                    Expanded(
                      child: Text(
                        'MEJA [${meja.name.toUpperCase()}]',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            // Scrollable body
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Guest count
                    ColoredBox(
                      color: Colors.grey.shade800,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x4,
                          vertical: AppSpacing.x3,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.x2),
                            Text(
                              ': $_jumlahTamu',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Transactions
                    ..._transaksiList.map(
                      (t) => _TransaksiBlock(transaksi: t),
                    ),
                    // Grand total
                    ColoredBox(
                      color: AppColors.primary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x4,
                          vertical: AppSpacing.x4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Total',
                              style: AppTypography.textTheme.titleSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            Text(
                              'Rp ${_fmtNum(_grandTotal)}',
                              textAlign: TextAlign.center,
                              style: AppTypography.textTheme.headlineSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

class _TransaksiBlock extends StatelessWidget {
  const _TransaksiBlock({required this.transaksi});

  final _MockTransaksi transaksi;

  static const _green = Color(0xFF4CAF50);

  Widget _summaryRow(String label, String value) => ColoredBox(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.textTheme.bodySmall
                      ?.copyWith(color: Colors.black87),
                ),
              ),
              Text(
                value,
                style: AppTypography.textTheme.bodySmall
                    ?.copyWith(color: Colors.black87),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Transaction code header
        ColoredBox(
          color: Colors.grey.shade800,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '*${transaksi.code}*',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '00:00',
                  style: AppTypography.textTheme.bodySmall
                      ?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
        // Column headers
        ColoredBox(
          color: Colors.grey.shade700,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Item',
                    style: AppTypography.textTheme.bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'Total',
                    textAlign: TextAlign.end,
                    style: AppTypography.textTheme.bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Item rows
        ...transaksi.items.asMap().entries.map((e) {
          final item = e.value;
          return ColoredBox(
            color: e.key.isEven ? Colors.white : Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      _fmtNum(item.price),
                      textAlign: TextAlign.end,
                      style: AppTypography.textTheme.bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${item.qty}x',
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      _fmtNum(item.total),
                      textAlign: TextAlign.end,
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        // Summary rows
        _summaryRow('Jumlah Item :', transaksi.jumlahItem.toString()),
        _summaryRow('Subtotal :', _fmtNum(transaksi.subtotal)),
        _summaryRow('Pajak : 2%', _fmtNum(transaksi.pajak)),
        _summaryRow('Biaya Layanan : 2%', _fmtNum(transaksi.biayaLayanan)),
        // Transaction total (green)
        ColoredBox(
          color: _green,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total :',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _fmtNum(transaksi.grandTotal),
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Ganti meja confirm dialog ─────────────────────────────────────────────────

class _GantiMejaConfirmDialog extends StatelessWidget {
  const _GantiMejaConfirmDialog({required this.mejaNama});

  final String mejaNama;

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
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz_rounded,
                        color: AppColors.onPrimary, size: 22),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'Ganti Meja $mejaNama',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close, color: AppColors.onPrimary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            ColoredBox(
              color: _bodyColor,
              child: _MejaOption(
                icon: Icons.check_rounded,
                label: 'Pilih Meja',
                onTap: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
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
