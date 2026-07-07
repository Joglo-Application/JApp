import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/kitchen/presentation/widgets/navigation/kitchen_drawer.dart';
import '../../../features/pos/presentation/widgets/navigation/pos_drawer.dart';
import '../../../features/spv/presentation/widgets/navigation/spv_drawer.dart';
import '../../../features/supplier/presentation/widgets/navigation/supplier_drawer.dart';

/// Drawer matching the logged-in user's role, for pages reachable from every
/// role's drawer footer (Absensi, Pengaturan) — so opening them never swaps
/// the menu to another role's drawer.
Widget roleDrawer(BuildContext context, {bool absensiActive = false}) {
  final role = context.select<AuthProvider, String?>((a) => a.user?.role);
  return switch (role) {
    'supervisor' => SpvDrawer(
        activePage: absensiActive ? SpvDrawerPage.absensi : null,
      ),
    'dapur' => const KitchenDrawer(),
    'gudang' => const SupplierDrawer(),
    _ => absensiActive
        ? const PosDrawer(activePage: PosDrawerPage.absensi)
        : const PosDrawer(),
  };
}
