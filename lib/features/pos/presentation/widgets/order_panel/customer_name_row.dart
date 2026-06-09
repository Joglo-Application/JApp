import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../pages/pesanan_pending_page.dart';
import '../../pages/pilih_member_page.dart';
import '../../providers/order_provider.dart';

class CustomerNameRow extends StatelessWidget {
  const CustomerNameRow({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final name = provider.customerName;
    final label = name.isEmpty ? 'Name Customer' : name;
    final orderType = provider.orderType;
    final memberPoints = provider.memberPoints;

    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                final provider = context.read<OrderProvider>();
                Navigator.push<SelectedMember>(
                  context,
                  MaterialPageRoute(builder: (_) => const PilihMemberPage()),
                ).then((member) {
                  if (member != null) provider.setMember(member.name, member.points);
                });
              },
              child: const Icon(
                Icons.account_circle_outlined,
                size: 22,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditDialog(context),
                child: memberPoints != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                label,
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.x1),
                              const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          Text(
                            'Point : $memberPoints',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x1),
                          const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          if (orderType != null) ...[
                            const SizedBox(width: AppSpacing.x2),
                            Text(
                              '(${orderType.label})',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
            GestureDetector(
              onTap: () => _showSavePendingDialog(context),
              child: const Icon(
                Icons.add,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavePendingDialog(BuildContext context) {
    final provider = context.read<OrderProvider>();
    if (provider.isEmpty) return;
    showDialog<String>(
      context: context,
      builder: (_) => _SavePendingDialog(initialName: provider.customerName),
    ).then((name) {
      if (name == null) return;
      addOrderToPending(
        customerName: name,
        items: provider.items.toList(),
      );
      provider.clear();
    });
  }

  void _showEditDialog(BuildContext context) {
    final provider = context.read<OrderProvider>();
    showDialog<String>(
      context: context,
      builder: (_) => _CustomerNameDialog(initialName: provider.customerName),
    ).then((name) {
      if (name != null) provider.setCustomerName(name);
    });
  }
}

// ── Dialog ────────────────────────────────────────────────────────────────────

class _CustomerNameDialog extends StatefulWidget {
  const _CustomerNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_CustomerNameDialog> createState() => _CustomerNameDialogState();
}

class _CustomerNameDialogState extends State<_CustomerNameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, _ctrl.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customer Name'),
      content: AppTextField(
        controller: _ctrl,
        label: 'Name',
        hint: 'Enter customer name',
        autofocus: true,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── Save to pending dialog ────────────────────────────────────────────────────

class _SavePendingDialog extends StatefulWidget {
  const _SavePendingDialog({required this.initialName});

  final String initialName;

  @override
  State<_SavePendingDialog> createState() => _SavePendingDialogState();
}

class _SavePendingDialogState extends State<_SavePendingDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() => Navigator.pop(context, _ctrl.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Masukkan Nama',
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _confirm(),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.outline),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        cursorColor: AppColors.primary,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'BATAL',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: _confirm,
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
