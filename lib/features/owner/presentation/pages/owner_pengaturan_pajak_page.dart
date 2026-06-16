import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/pengaturan/pengaturan_form_widgets.dart';

class OwnerPengaturanPajakPage extends StatefulWidget {
  const OwnerPengaturanPajakPage({super.key});

  @override
  State<OwnerPengaturanPajakPage> createState() =>
      _OwnerPengaturanPajakPageState();
}

class _OwnerPengaturanPajakPageState extends State<OwnerPengaturanPajakPage> {
  bool _pajakTokoAktif = true;
  bool _biayaLayananAktif = true;
  bool _ppnAktif = false;
  bool _taxAktif = false;

  final _namaPajakController = TextEditingController(text: 'Pajak Toko');
  final _persentasePajakController = TextEditingController(text: '2');
  final _persentaseBiayaLayananController = TextEditingController(text: '2');
  final _persentasePpnController = TextEditingController(text: '2');
  final _persentaseTaxController = TextEditingController(text: '2');

  @override
  void dispose() {
    _namaPajakController.dispose();
    _persentasePajakController.dispose();
    _persentaseBiayaLayananController.dispose();
    _persentasePpnController.dispose();
    _persentaseTaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            PengaturanDetailTopBar(
              title: 'Pajak & Biaya',
              onSave: () => Navigator.of(context).pop(),
              onClose: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Pajak Toko ───────────────────────────────────────────
                    const PengaturanSectionHeader(label: 'Pajak Toko'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Aktifkan Pajak Toko',
                      value: _pajakTokoAktif,
                      onChanged: (v) => setState(() => _pajakTokoAktif = v),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    const PengaturanSubLabel(label: 'Nama Pajak'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloTextField(controller: _namaPajakController),
                    const SizedBox(height: AppSpacing.x3),
                    const PengaturanSubLabel(label: 'Persentase Pajak'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloTextField(
                      controller: _persentasePajakController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: AppSpacing.x5),

                    // ── Biaya Layanan ────────────────────────────────────────
                    const PengaturanSectionHeader(label: 'Biaya Layanan'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Aktifkan Biaya Layanan',
                      value: _biayaLayananAktif,
                      onChanged: (v) => setState(() => _biayaLayananAktif = v),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    const PengaturanSubLabel(label: 'Persentase Pajak'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloTextField(
                      controller: _persentaseBiayaLayananController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: AppSpacing.x5),

                    // ── PPN ──────────────────────────────────────────────────
                    const PengaturanSectionHeader(label: 'PPN'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Aktifkan PPN',
                      value: _ppnAktif,
                      onChanged: (v) => setState(() => _ppnAktif = v),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    const PengaturanSubLabel(label: 'Persentase Pajak'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloTextField(
                      controller: _persentasePpnController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: AppSpacing.x5),

                    // ── TAX ──────────────────────────────────────────────────
                    const PengaturanSectionHeader(label: 'TAX'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Aktifkan TAX',
                      value: _taxAktif,
                      onChanged: (v) => setState(() => _taxAktif = v),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    const PengaturanSubLabel(label: 'Persentase Pajak'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloTextField(
                      controller: _persentaseTaxController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: AppSpacing.x8),
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
