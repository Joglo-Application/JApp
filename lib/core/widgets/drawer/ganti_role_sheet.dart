import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class GantiRoleAccount {
  const GantiRoleAccount({required this.namaUser, required this.roleCode});

  final String namaUser;
  final String roleCode;
}

class GantiRoleSheet extends StatelessWidget {
  const GantiRoleSheet({
    super.key,
    required this.accounts,
    this.onSelect,
  });

  final List<GantiRoleAccount> accounts;
  final void Function(GantiRoleAccount account)? onSelect;

  static void show(
    BuildContext context, {
    required List<GantiRoleAccount> accounts,
    void Function(GantiRoleAccount)? onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GantiRoleSheet(accounts: accounts, onSelect: onSelect),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.65,
      child: Column(
        children: [
          _SheetHeader(onClose: () => Navigator.of(context).pop()),
          Expanded(
            child: ColoredBox(
              color: AppColors.onPrimaryContainer,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: accounts.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white12,
                ),
                itemBuilder: (_, i) => _RoleTile(
                  account: accounts[i],
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect?.call(accounts[i]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x4,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.switch_account_rounded,
                color: AppColors.onPrimary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Text(
                  'Ganti Role',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.onPrimary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Role tile ───────────────────────────────────────────────────────────────

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.account, required this.onTap});

  final GantiRoleAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              account.namaUser,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              account.roleCode,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
