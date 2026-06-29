import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/checkout_remote_datasource.dart';
import '../../domain/entities/order_item.dart';
import '../providers/order_provider.dart';

const _kGold = Color(0xFFC9A227);

/// Jumlah draft "held" (untuk badge tombol Pending). Diisi dari backend.
final pendingCountNotifier = ValueNotifier<int>(0);

/// Daftar draft held terkini (sumber data halaman Pending) — dari backend.
final List<_PendingOrder> _heldOrders = [];

final _pendingDatasource = CheckoutRemoteDatasourceImpl();

/// Ambil ulang daftar draft dari backend (GET /pesanan?status=pending).
Future<void> refreshPendingOrders() async {
  try {
    final drafts = await _pendingDatasource.fetchHeldOrders();
    _heldOrders
      ..clear()
      ..addAll(drafts.map((d) {
        final dt = d.createdAt ?? DateTime.now();
        final nama = (d.customerNama ?? '').isEmpty ? 'Customer' : d.customerNama!;
        return _PendingOrder(
          pesananId: d.pesananId,
          customerName: nama,
          date: _formatDate(dt),
          time: _formatTime(dt),
          total: d.total,
          items: d.items
              .map((it) => _Item(
                    productId: it.menuId?.toString() ?? 'custom-${it.detailId}',
                    name: it.nama,
                    unitPrice: it.hargaSatuan.toDouble(),
                    qty: it.jumlah,
                  ))
              .toList(),
        );
      }));
    pendingCountNotifier.value = _heldOrders.length;
  } catch (_) {
    // Non-kritis: biarkan daftar apa adanya bila gagal memuat.
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  return '$d ${_months[dt.month - 1]} ${dt.year}';
}

String _formatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

// ── Model tampilan draft ────────────────────────────────────────────────────

class _Item {
  const _Item({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.qty,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int qty;
}

class _PendingOrder {
  const _PendingOrder({
    required this.pesananId,
    required this.customerName,
    required this.date,
    required this.time,
    required this.total,
    required this.items,
  });

  final int pesananId;
  final String customerName;
  final String date;
  final String time;
  final int total;
  final List<_Item> items;

  String get id => pesananId.toString();

  String get itemSummary =>
      items.map((i) => '${i.qty}x ${i.name}').join(', ');
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

// ── Page ──────────────────────────────────────────────────────────────────────

class PesananPendingPage extends StatefulWidget {
  const PesananPendingPage({super.key});

  @override
  State<PesananPendingPage> createState() => _PesananPendingPageState();
}

class _PesananPendingPageState extends State<PesananPendingPage> {
  String? _selectedId;
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await refreshPendingOrders();
    if (mounted) setState(() => _loading = false);
  }

  List<_PendingOrder> get _filteredOrders {
    if (_searchQuery.isEmpty) return _heldOrders;
    final q = _searchQuery.toLowerCase();
    return _heldOrders
        .where((o) =>
            o.customerName.toLowerCase().contains(q) ||
            o.itemSummary.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _onGabungTap() async {
    final selectedIds = await showDialog<List<String>>(
      context: context,
      builder: (_) => _GabungDialog(preSelectedId: _selectedId),
    );
    if (!mounted || selectedIds == null || selectedIds.isEmpty) return;

    final orders =
        _heldOrders.where((o) => selectedIds.contains(o.id)).toList();
    final provider = context.read<OrderProvider>();

    provider.setCustomerName(orders.first.customerName);
    for (final order in orders) {
      for (final item in order.items) {
        provider.addOrIncrement(OrderItem(
          productId: item.productId,
          name: item.name,
          unitPrice: item.unitPrice,
          quantity: item.qty,
        ));
      }
    }

    // Consume draft di backend (sudah dimuat ke POS) lalu refresh daftar.
    for (final order in orders) {
      try {
        await _pendingDatasource.deleteHeldOrder(order.pesananId);
      } catch (_) {
        // abaikan; draft mungkin sudah terhapus
      }
    }
    await refreshPendingOrders();

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _PesananPendingHeader(
              onSearchChanged: (q) => setState(() => _searchQuery = q),
              onGabung: _onGabungTap,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada pesanan pending',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredOrders.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.outlineVariant,
                      ),
                      itemBuilder: (_, i) {
                        final order = _filteredOrders[i];
                        final isSelected = order.id == _selectedId;
                        return _OrderRow(
                          order: order,
                          isSelected: isSelected,
                          onTap: () => setState(() {
                            _selectedId = isSelected ? null : order.id;
                          }),
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

class _PesananPendingHeader extends StatefulWidget {
  const _PesananPendingHeader({
    required this.onSearchChanged,
    required this.onGabung,
    required this.onClose,
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onGabung;
  final VoidCallback onClose;

  @override
  State<_PesananPendingHeader> createState() => _PesananPendingHeaderState();
}

class _PesananPendingHeaderState extends State<_PesananPendingHeader> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showSearch
                  ? SizedBox(
                      key: const ValueKey('search-field'),
                      width: 220,
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: AppTypography.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: 'Cari pesanan...',
                          hintStyle: AppTypography.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white54),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.x3,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.15),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.md,
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white54, size: 20),
                            onPressed: () {
                              setState(() => _showSearch = false);
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                          ),
                        ),
                        onChanged: widget.onSearchChanged,
                      ),
                    )
                  : Material(
                      key: const ValueKey('search-button'),
                      color: AppColors.primary,
                      borderRadius: AppRadius.md,
                      child: InkWell(
                        onTap: () => setState(() => _showSearch = true),
                        borderRadius: AppRadius.md,
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.search_rounded,
                              color: AppColors.onPrimary, size: 26),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Text(
                'Pesanan Pending',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Material(
              color: _kGold,
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: widget.onGabung,
                borderRadius: AppRadius.md,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x5,
                    vertical: AppSpacing.x3,
                  ),
                  child: Text(
                    'Gabung',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            Material(
              color: AppColors.error,
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: widget.onClose,
                borderRadius: AppRadius.md,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.close_rounded,
                      color: AppColors.onError, size: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order row (main list) ─────────────────────────────────────────────────────

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  final _PendingOrder order;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryContainer : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 4,
                height: 42,
                margin: const EdgeInsets.only(right: AppSpacing.x3),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.sm,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.customerName,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.x3),
                        Text(
                          order.date,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.x2),
                        Text(
                          order.time,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text(
                      order.itemSummary,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _fmtNum(order.total),
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
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

// ── Gabung dialog ─────────────────────────────────────────────────────────────

class _GabungDialog extends StatefulWidget {
  const _GabungDialog({required this.preSelectedId});

  final String? preSelectedId;

  @override
  State<_GabungDialog> createState() => _GabungDialogState();
}

class _GabungDialogState extends State<_GabungDialog> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected =
        widget.preSelectedId != null ? {widget.preSelectedId!} : {};
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.25,
        vertical: AppSpacing.x8,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            ColoredBox(
              color: _kGold,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x4,
                  AppSpacing.x4,
                  AppSpacing.x2,
                  AppSpacing.x4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Pilih Satu atau\nGabung beberapa Pesanan',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            // Order list
            Flexible(
              child: ColoredBox(
                color: Colors.white,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _heldOrders.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                  itemBuilder: (_, i) {
                    final order = _heldOrders[i];
                    final checked = _selected.contains(order.id);
                    return _DialogOrderRow(
                      order: order,
                      checked: checked,
                      onTap: () => _toggle(order.id),
                    );
                  },
                ),
              ),
            ),
            // Footer
            ColoredBox(
              color: _kGold,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(null),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.x4),
                        child: Text(
                          'BATAL',
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: Colors.white60,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _selected.isEmpty
                          ? null
                          : () =>
                              Navigator.of(context).pop(_selected.toList()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.x4),
                        child: Text(
                          'PILIH',
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: _selected.isEmpty
                                ? Colors.white38
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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

// ── Dialog order row ──────────────────────────────────────────────────────────

class _DialogOrderRow extends StatelessWidget {
  const _DialogOrderRow({
    required this.order,
    required this.checked,
    required this.onTap,
  });

  final _PendingOrder order;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _GoldCheckbox(checked: checked),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.customerName,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x2),
                      Text(
                        '${order.date}  ${order.time}',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    order.itemSummary,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  _fmtNum(order.total),
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
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

class _GoldCheckbox extends StatelessWidget {
  const _GoldCheckbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: checked ? _kGold : Colors.transparent,
        border: Border.all(
          color: checked ? _kGold : AppColors.outline,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}
