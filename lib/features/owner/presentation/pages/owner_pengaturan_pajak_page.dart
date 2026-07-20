import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/datasources/pengaturan_remote_datasource.dart';
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

  final _datasource = PengaturanRemoteDatasource();
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final d = await _datasource.fetchGrup('pajak');
      if (!mounted) return;
      setState(() {
        _pajakTokoAktif = d['pajakAktif'] == true;
        _biayaLayananAktif = d['biayaLayananAktif'] == true;
        _ppnAktif = d['ppnAktif'] == true;
        _taxAktif = d['taxAktif'] == true;
        _namaPajakController.text = (d['namaPajak'] ?? 'Pajak Toko').toString();
        _persentasePajakController.text = _teks(d['pajakPersen']);
        _persentaseBiayaLayananController.text = _teks(d['biayaLayananPersen']);
        _persentasePpnController.text = _teks(d['ppnPersen']);
        _persentaseTaxController.text = _teks(d['taxPersen']);
      });
    } on ApiException {
      // Biarkan nilai bawaan form bila gagal dimuat.
    }
  }

  static String _teks(dynamic v) => ((v as num?) ?? 0).toString();

  static double _angka(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  Future<void> _simpan() async {
    if (_menyimpan) return;
    setState(() => _menyimpan = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await _datasource.simpanGrup('pajak', {
        'pajakAktif': _pajakTokoAktif,
        'namaPajak': _namaPajakController.text.trim(),
        'pajakPersen': _angka(_persentasePajakController),
        'biayaLayananAktif': _biayaLayananAktif,
        'biayaLayananPersen': _angka(_persentaseBiayaLayananController),
        'ppnAktif': _ppnAktif,
        'ppnPersen': _angka(_persentasePpnController),
        'taxAktif': _taxAktif,
        'taxPersen': _angka(_persentaseTaxController),
      });
      navigator.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

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
              onSave: _simpan,
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
