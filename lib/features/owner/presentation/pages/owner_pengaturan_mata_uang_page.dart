import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/datasources/pengaturan_remote_datasource.dart';
import '../widgets/pengaturan/pengaturan_form_widgets.dart';

class OwnerPengaturanMataUangPage extends StatefulWidget {
  const OwnerPengaturanMataUangPage({super.key});

  @override
  State<OwnerPengaturanMataUangPage> createState() =>
      _OwnerPengaturanMataUangPageState();
}

class _OwnerPengaturanMataUangPageState
    extends State<OwnerPengaturanMataUangPage> {
  final _datasource = PengaturanRemoteDatasource();
  String _mataUang = 'Rupiah';
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final data = await _datasource.fetchGrup('mataUang');
      if (!mounted) return;
      setState(() => _mataUang = (data['nama'] ?? 'Rupiah').toString());
    } on ApiException {
      // Biarkan nilai default; pengguna tetap bisa memilih dan menyimpan.
    }
  }

  Future<void> _simpan() async {
    if (_menyimpan) return;
    setState(() => _menyimpan = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await _datasource.simpanGrup('mataUang', {'nama': _mataUang});
      navigator.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            PengaturanDetailTopBar(
              title: 'Mata Uang Penjualan',
              onSave: _simpan,
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
