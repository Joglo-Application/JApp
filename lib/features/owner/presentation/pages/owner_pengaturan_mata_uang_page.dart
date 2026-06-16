import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/pengaturan/pengaturan_form_widgets.dart';

class OwnerPengaturanMataUangPage extends StatefulWidget {
  const OwnerPengaturanMataUangPage({super.key});

  @override
  State<OwnerPengaturanMataUangPage> createState() =>
      _OwnerPengaturanMataUangPageState();
}

class _OwnerPengaturanMataUangPageState
    extends State<OwnerPengaturanMataUangPage> {
  String _mataUang = 'Rupiah';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            PengaturanDetailTopBar(
              title: 'Mata Uang Penjualan',
              onSave: () => Navigator.of(context).pop(),
              onClose: () => Navigator.of(context).pop(),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PengaturanSectionHeader(
                      label: 'Mata Uang Penjualan',
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppBreakpoint.sidebarWidth,
                      ),
                      child: PengaturanSoloDropdownField(
                        value: _mataUang,
                        options: const ['Rupiah'],
                        placeholder: 'Pilih Mata Uang',
                        onChanged: (v) => setState(() => _mataUang = v),
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
