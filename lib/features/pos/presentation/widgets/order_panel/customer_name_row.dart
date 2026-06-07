import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../providers/order_provider.dart';

class CustomerNameRow extends StatelessWidget {
  const CustomerNameRow({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.watch<OrderProvider>().customerName;
    final label = name.isEmpty ? 'Name Customer' : name;

    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 22,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Row(
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
              ),
            ),
            GestureDetector(
              onTap: () {},
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
