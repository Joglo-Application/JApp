import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaksi.dart';
import '../../providers/transaksi_provider.dart';
import '../shared/pin_supervisor_dialog.dart';

class TransaksiDetailPanel extends StatelessWidget {
  const TransaksiDetailPanel({super.key});

  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String formatDatetime(DateTime dt) {
    final day = _days[dt.weekday - 1];
    final month = _months[dt.month - 1];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$day, ${dt.day} $month ${dt.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final trx = context.select<TransaksiProvider, Transaksi?>(
      (p) => p.selected,
    );
    if (trx == null) return const SizedBox.shrink();

    final panelWidth = (MediaQuery.sizeOf(context).width * 0.46).clamp(320.0, 560.0);

    return SizedBox(
      width: panelWidth,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(left: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Column(
          children: [
            _PanelHeader(kode: trx.kode, isReturned: trx.isReturned),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _InfoSection(trx: trx),
                  const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
                  _ItemTable(items: trx.items),
                  _SummarySection(trx: trx),
                ],
              ),
            ),
            _PanelFooter(total: trx.total, isReturned: trx.isReturned),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.kode, required this.isReturned});

  final String kode;
  final bool isReturned;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isReturned ? AppColors.error : AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                kode,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => context.read<TransaksiProvider>().select(null),
              icon: const Icon(Icons.close_rounded, color: AppColors.onPrimary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info rows ─────────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.trx});

  final Transaksi trx;

  @override
  Widget build(BuildContext context) {
    final contactLabel = trx.namaKontak.isNotEmpty ? trx.namaKontak : '-';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.access_time_rounded,
            text: TransaksiDetailPanel.formatDatetime(trx.waktu),
          ),
          const SizedBox(height: AppSpacing.x3),
          _InfoRow(icon: Icons.person_rounded, text: trx.namaStaff),
          const SizedBox(height: AppSpacing.x3),
          _InfoRow(icon: Icons.people_rounded, text: '$contactLabel / [-]'),
          const SizedBox(height: AppSpacing.x3),
          _InfoRow(
            icon: Icons.monetization_on_rounded,
            text: trx.tipePembayaran,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: Text(
            text,
            style: AppTypography.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// ── Item table ────────────────────────────────────────────────────────────────

class _ItemTable extends StatelessWidget {
  const _ItemTable({required this.items});

  final List<TransaksiItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TableHeader(),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
          _ItemRow(item: items[i]),
        ],
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            _HeaderCell('Item', flex: 1, align: TextAlign.start),
            _HeaderCell('Qty', width: 48, align: TextAlign.center),
            _HeaderCell('Total', width: 96, align: TextAlign.end),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.flex, this.width, required this.align});

  final String label;
  final int? flex;
  final double? width;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: AppTypography.textTheme.labelMedium?.copyWith(
        color: AppColors.onSecondary,
        fontWeight: FontWeight.bold,
      ),
      textAlign: align,
    );
    if (flex != null) return Expanded(flex: flex!, child: child);
    return SizedBox(width: width, child: child);
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final TransaksiItem item;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nama, style: AppTypography.textTheme.bodyMedium),
                Text(
                  CurrencyFormatter.format(item.hargaSatuan),
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${item.qty}',
              style: AppTypography.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 96,
            child: Text(
              CurrencyFormatter.format(item.total),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary ───────────────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.trx});

  final Transaksi trx;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
        _SummaryRow('Subtotal', CurrencyFormatter.format(trx.subtotal), tinted: false),
        _SummaryRow(
          'Biaya Layanan ${trx.biayaLayananPct.toInt()}%',
          CurrencyFormatter.format(trx.biayaLayanan),
          tinted: true,
        ),
        _SummaryRow(
          'Pajak Toko ${trx.pajakTokoPct.toInt()}%',
          CurrencyFormatter.format(trx.pajakToko),
          tinted: false,
        ),
        _SummaryRow('Jumlah Item', '${trx.jumlahItem}', tinted: true),
        _SummaryRow('Dilayani Oleh', trx.namaStaff, tinted: false),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {required this.tinted});

  final String label;
  final String value;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: tinted ? AppColors.background : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTypography.textTheme.bodyMedium),
            ),
            Text(
              value,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _PanelFooter extends StatelessWidget {
  const _PanelFooter({required this.total, required this.isReturned});

  final double total;
  final bool isReturned;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isReturned ? AppColors.error : AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Text(
              'Total',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            Expanded(
              child: Text(
                CurrencyFormatter.format(total),
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _ShareButton(),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatefulWidget {
  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton> {
  final _key = GlobalKey();
  OverlayEntry? _overlay;

  void _show() {
    final box = _key.currentContext!.findRenderObject()! as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screen = MediaQuery.sizeOf(context);

    _overlay?.remove();
    _overlay = OverlayEntry(
      builder: (_) => _ActionMenu(
        bottom: screen.height - offset.dy,
        right: screen.width - offset.dx - size.width,
        onClose: _dismiss,
        onPengembalianBatal: _startPengembalianBatalFlow,
        onSmsWhatsApp: _showWhatsAppDialog,
        onEmail: _showEmailDialog,
        onCetak: _showCetakBerhasil,
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _dismiss() {
    _overlay?.remove();
    _overlay = null;
  }

  void _startPengembalianBatalFlow() {
    _dismiss();
    showDialog<void>(
      context: context,
      builder: (_) => _PilihDialog(
        onConfirm: (isPengembalian) {
          if (isPengembalian) {
            _showAlasanDialog();
          } else {
            _showPinDialog(null);
          }
        },
      ),
    );
  }

  void _showAlasanDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _AlasanPengembalianDialog(
        onNext: _showPinDialog,
      ),
    );
  }

  void _showWhatsAppDialog() {
    _dismiss();
    showDialog<void>(
      context: context,
      builder: (_) => const _ResiInputDialog(
        title: 'WhatsApp Resi',
        subtitle: 'Mohon masukkan no.handphone penerima',
        hint: 'Telpon Penerima',
        keyboardType: TextInputType.phone,
      ),
    );
  }

  void _showEmailDialog() {
    _dismiss();
    showDialog<void>(
      context: context,
      builder: (_) => const _ResiInputDialog(
        title: 'Email Resi',
        subtitle: 'Mohon masukkan email penerima',
        hint: 'Email Penerima',
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  void _showCetakBerhasil() {
    _dismiss();
    showDialog<void>(
      context: context,
      builder: (_) => const _CetakBerhasilDialog(),
    );
  }

  Future<void> _showPinDialog(String? alasan) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const PinSupervisorDialog(),
    );
    if (ok == true && mounted) {
      final kode = context.read<TransaksiProvider>().selected?.kode;
      if (kode != null) {
        context.read<TransaksiProvider>().markAsReturned(kode);
      }
    }
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      decoration: BoxDecoration(
        color: AppColors.onPrimaryContainer,
        borderRadius: AppRadius.sm,
      ),
      child: IconButton(
        onPressed: _show,
        icon: const Icon(Icons.share_rounded, color: AppColors.onPrimary),
        iconSize: 20,
        padding: const EdgeInsets.all(AppSpacing.x2),
        constraints: const BoxConstraints(),
      ),
    );
  }
}

// ── Action menu overlay ────────────────────────────────────────────────────────

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.bottom,
    required this.right,
    required this.onClose,
    required this.onPengembalianBatal,
    required this.onSmsWhatsApp,
    required this.onEmail,
    required this.onCetak,
  });

  final double bottom;
  final double right;
  final VoidCallback onClose;
  final VoidCallback onPengembalianBatal;
  final VoidCallback onSmsWhatsApp;
  final VoidCallback onEmail;
  final VoidCallback onCetak;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: const ColoredBox(
            color: AppColors.scrim,
            child: SizedBox.expand(),
          ),
        ),
        Positioned(
          bottom: bottom,
          right: right,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ActionItem(
                label: 'Lihat Log',
                icon: Icons.receipt_long_rounded,
                color: AppColors.warning,
                onTap: onClose,
              ),
              const SizedBox(height: AppSpacing.x2),
              _ActionItem(
                label: 'Pengembalian/Batal',
                icon: Icons.delete_rounded,
                color: AppColors.error,
                onTap: onPengembalianBatal,
              ),
              const SizedBox(height: AppSpacing.x2),
              _ActionItem(
                label: 'SMS/WhatsApp',
                icon: Icons.chat_bubble_rounded,
                color: AppColors.warning,
                onTap: onSmsWhatsApp,
              ),
              const SizedBox(height: AppSpacing.x2),
              _ActionItem(
                label: 'Email',
                icon: Icons.email_rounded,
                color: AppColors.primary,
                onTap: onEmail,
              ),
              const SizedBox(height: AppSpacing.x2),
              _ActionItem(
                label: 'Cetak',
                icon: Icons.print_rounded,
                color: AppColors.warning,
                onTap: onCetak,
              ),
              const SizedBox(height: AppSpacing.x3),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.onError,
                    size: 20,
                  ),
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

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.onPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Pengembalian/Batal dialogs ────────────────────────────────────────────────

class _PilihDialog extends StatefulWidget {
  const _PilihDialog({required this.onConfirm});

  final void Function(bool isPengembalian) onConfirm;

  @override
  State<_PilihDialog> createState() => _PilihDialogState();
}

class _PilihDialogState extends State<_PilihDialog> {
  bool _pengembalian = false;
  bool _batalPesanan = false;

  bool get _canConfirm => _pengembalian || _batalPesanan;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: AppRadius.toShape(AppRadius.md),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x3,
              ),
              child: Text(
                'Pilih',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          CheckboxListTile(
            value: _pengembalian,
            onChanged: (v) => setState(() {
              _pengembalian = v!;
              if (v) _batalPesanan = false;
            }),
            title: Text('Pengembalian', style: AppTypography.textTheme.bodyMedium),
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
          ),
          CheckboxListTile(
            value: _batalPesanan,
            onChanged: (v) => setState(() {
              _batalPesanan = v!;
              if (v) _pengembalian = false;
            }),
            title: Text('Batal Pesanan', style: AppTypography.textTheme.bodyMedium),
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'BATAL',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.x4),
                TextButton(
                  onPressed: _canConfirm
                      ? () {
                          Navigator.of(context).pop();
                          widget.onConfirm(_pengembalian);
                        }
                      : null,
                  child: Text(
                    'KONFIRMASI',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: _canConfirm ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
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

class _AlasanPengembalianDialog extends StatefulWidget {
  const _AlasanPengembalianDialog({required this.onNext});

  final void Function(String alasan) onNext;

  @override
  State<_AlasanPengembalianDialog> createState() =>
      _AlasanPengembalianDialogState();
}

class _AlasanPengembalianDialogState extends State<_AlasanPengembalianDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: AppRadius.toShape(AppRadius.md),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengembalian',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Apa alasan pengembalian pesanan ini?',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            TextField(
              controller: _ctrl,
              style: AppTypography.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Alasan Pengembalian',
                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'BATAL',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.x4),
                TextButton(
                  onPressed: () {
                    final alasan = _ctrl.text.trim();
                    Navigator.of(context).pop();
                    widget.onNext(alasan);
                  },
                  child: Text(
                    'ULASAN',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
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

// ── Resi input dialog (WhatsApp & Email) ──────────────────────────────────────

class _ResiInputDialog extends StatefulWidget {
  const _ResiInputDialog({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.keyboardType,
  });

  final String title;
  final String subtitle;
  final String hint;
  final TextInputType keyboardType;

  @override
  State<_ResiInputDialog> createState() => _ResiInputDialogState();
}

class _ResiInputDialogState extends State<_ResiInputDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: AppRadius.toShape(AppRadius.md),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              widget.subtitle,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            TextField(
              controller: _ctrl,
              keyboardType: widget.keyboardType,
              style: AppTypography.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'BATAL',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.x4),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
    );
  }
}

// ── Cetak berhasil dialog ─────────────────────────────────────────────────────

class _CetakBerhasilDialog extends StatelessWidget {
  const _CetakBerhasilDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: AppRadius.toShape(AppRadius.md),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.tertiary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.onTertiary,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Cetak Berhasil',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
          ],
        ),
      ),
    );
  }
}
