import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/datasources/pengaturan_remote_datasource.dart';
import '../widgets/pengaturan/pengaturan_form_widgets.dart';

class OwnerPengaturanPosPage extends StatefulWidget {
  const OwnerPengaturanPosPage({super.key});

  @override
  State<OwnerPengaturanPosPage> createState() => _OwnerPengaturanPosPageState();
}

class _OwnerPengaturanPosPageState extends State<OwnerPengaturanPosPage> {
  // Sengaja tidak lagi diisi '123456'. PIN persetujuan kini diverifikasi ke
  // server lewat POST /auth/verify-pin dan tidak disimpan di pengaturan —
  // menampilkan nilai di sini akan menyesatkan seolah itu PIN yang berlaku.
  final _passKeyController = TextEditingController();

  // Pembulatan Pembayaran
  bool _pembulatanAktif = true;

  // Ext settings
  bool _harisPilihMeja = true;
  bool _diskonPesanan = true;
  bool _catatanPesanan = true;
  bool _inAway = true;
  bool _splitBill = true;

  final _datasource = PengaturanRemoteDatasource();
  String _emailPenerima = '';
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final pos = await _datasource.fetchGrup('pos');
      final notif = await _datasource.fetchGrup('notifikasi');
      if (!mounted) return;
      setState(() {
        _pembulatanAktif = pos['pembulatan'] == true;
        _harisPilihMeja = pos['harusPilihMeja'] == true;
        _diskonPesanan = pos['diskonPesanan'] == true;
        _catatanPesanan = pos['catatanPesanan'] == true;
        _inAway = pos['inAway'] == true;
        _splitBill = pos['splitBill'] == true;
        final daftar = notif['emailPenerima'] as List<dynamic>? ?? const [];
        _emailPenerima = daftar.isEmpty ? '' : daftar.first.toString();
      });
    } on ApiException {
      // Biarkan nilai bawaan form bila gagal dimuat.
    }
  }

  Future<void> _simpan() async {
    if (_menyimpan) return;
    setState(() => _menyimpan = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await _datasource.simpanGrup('pos', {
        'pembulatan': _pembulatanAktif,
        'harusPilihMeja': _harisPilihMeja,
        'diskonPesanan': _diskonPesanan,
        'catatanPesanan': _catatanPesanan,
        'inAway': _inAway,
        'splitBill': _splitBill,
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
    _passKeyController.dispose();
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
              title: 'Point of Sale',
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
                    // ── Email Laporan ───────────────────────────────────────
                    const PengaturanSectionHeader(label: 'Email Laporan'),
                    const SizedBox(height: AppSpacing.x2),
                    const PengaturanSubLabel(label: 'Email Penerima'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloNavRow(
                      label: 'Email',
                      value: _emailPenerima.isEmpty
                          ? 'Belum diatur'
                          : _emailPenerima,
                      onTap: () {},
                    ),

                    const SizedBox(height: AppSpacing.x5),

                    // ── Pass KEY ────────────────────────────────────────────
                    const PengaturanSectionHeader(label: 'Point of Sale Pass KEY'),
                    const SizedBox(height: AppSpacing.x2),
                    const PengaturanSubLabel(label: 'Pass KEY – SPV'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloTextField(controller: _passKeyController),

                    const SizedBox(height: AppSpacing.x5),

                    // ── Pembulatan Pembayaran ───────────────────────────────
                    const PengaturanSectionHeader(label: 'Pembulatan Pembayaran'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Aktifkan',
                      value: _pembulatanAktif,
                      onChanged: (v) => setState(() => _pembulatanAktif = v),
                    ),

                    const SizedBox(height: AppSpacing.x5),

                    // ── Point of Sale Ext Settings ──────────────────────────
                    const PengaturanSectionHeader(label: 'Point of Sale Ext Settings'),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Harus memilih Meja terlebih dahulu',
                      value: _harisPilihMeja,
                      onChanged: (v) => setState(() => _harisPilihMeja = v),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Diskon Pesanan',
                      value: _diskonPesanan,
                      onChanged: (v) => setState(() => _diskonPesanan = v),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Catatan Pesanan',
                      value: _catatanPesanan,
                      onChanged: (v) => setState(() => _catatanPesanan = v),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'In/Away',
                      value: _inAway,
                      onChanged: (v) => setState(() => _inAway = v),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    PengaturanSoloToggleRow(
                      label: 'Split Bill',
                      value: _splitBill,
                      onChanged: (v) => setState(() => _splitBill = v),
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
