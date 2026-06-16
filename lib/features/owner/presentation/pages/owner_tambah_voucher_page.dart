import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class TambahVoucherResult {
  const TambahVoucherResult({
    required this.kode,
    required this.nama,
    required this.diskonDisplay,
    required this.tanggalAktif,
  });

  final String kode;
  final String nama;
  final String diskonDisplay;
  final String tanggalAktif;
}

enum _DiskonType { nominal, persen }

class OwnerTambahVoucherPage extends StatefulWidget {
  const OwnerTambahVoucherPage({super.key});

  @override
  State<OwnerTambahVoucherPage> createState() => _OwnerTambahVoucherPageState();
}

class _OwnerTambahVoucherPageState extends State<OwnerTambahVoucherPage> {
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _jumlahDiskonController = TextEditingController();
  final _maxDiskonController = TextEditingController();

  _DiskonType _diskonType = _DiskonType.nominal;
  DateTime _tanggalAktif = DateTime.now();
  DateTime _tanggalKedaluwarsa = DateTime.now();
  bool _tanpaKedaluwarsa = false;

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const _days = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu',
  ];

  String _formatDateFull(DateTime dt) =>
      '${_days[dt.weekday % 7]}, ${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  String _formatDateShort(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _jumlahDiskonController.dispose();
    _maxDiskonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormField(
                      label: 'Kode Voucher',
                      child: _OutlinedInput(
                        controller: _kodeController,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    _FormField(
                      label: 'Nama Voucher',
                      child: _OutlinedInput(controller: _namaController),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    _FormField(
                      label: 'Jumlah Diskon',
                      child: Row(
                        children: [
                          Expanded(
                            child: _OutlinedInput(
                              controller: _jumlahDiskonController,
                              keyboardType: TextInputType.number,
                              prefix: _diskonType == _DiskonType.nominal
                                  ? 'IDR  '
                                  : null,
                              suffix: _diskonType == _DiskonType.persen
                                  ? '%'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x2),
                          _DiskonTypeButton(
                            icon: Icons.attach_money_rounded,
                            active: _diskonType == _DiskonType.nominal,
                            onTap: () => setState(
                              () => _diskonType = _DiskonType.nominal,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x2),
                          _DiskonTypeButton(
                            icon: Icons.percent_rounded,
                            active: _diskonType == _DiskonType.persen,
                            onTap: () => setState(
                              () => _diskonType = _DiskonType.persen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    _FormField(
                      label: 'Max. Jumlah Diskon',
                      child: _OutlinedInput(
                        controller: _maxDiskonController,
                        keyboardType: TextInputType.number,
                        prefix: 'IDR  ',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    _FormField(
                      label: 'Tanggal Aktif',
                      child: _DatePickerField(
                        value: _formatDateFull(_tanggalAktif),
                        onTap: () => _pickDate(
                          initial: _tanggalAktif,
                          onPicked: (d) => setState(() => _tanggalAktif = d),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    Row(
                      children: [
                        Text(
                          'Tanpa Kedaluwarsa',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _tanpaKedaluwarsa,
                          onChanged: (v) =>
                              setState(() => _tanpaKedaluwarsa = v),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    if (!_tanpaKedaluwarsa) ...[
                      const SizedBox(height: AppSpacing.x4),
                      _DatePickerField(
                        value: _formatDateFull(_tanggalKedaluwarsa),
                        onTap: () => _pickDate(
                          initial: _tanggalKedaluwarsa,
                          onPicked: (d) =>
                              setState(() => _tanggalKedaluwarsa = d),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.x4),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Tambah Voucher',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: AppRadius.full,
            child: const Icon(Icons.close_rounded, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
              color: AppColors.error,
              alignment: Alignment.center,
              child: Text(
                'Batal',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _onSimpan,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
              color: Colors.green.shade600,
              alignment: Alignment.center,
              child: Text(
                'Simpan',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSimpan() {
    final kode = _kodeController.text.trim();
    final nama = _namaController.text.trim();
    final jumlah = _jumlahDiskonController.text.trim();

    if (kode.isEmpty || nama.isEmpty || jumlah.isEmpty) return;

    final diskonDisplay = _diskonType == _DiskonType.persen
        ? '$jumlah%'
        : 'IDR $jumlah';

    context.pop(TambahVoucherResult(
      kode: kode,
      nama: nama,
      diskonDisplay: diskonDisplay,
      tanggalAktif: _formatDateShort(_tanggalAktif),
    ));
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        child,
      ],
    );
  }
}

class _OutlinedInput extends StatelessWidget {
  const _OutlinedInput({
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.suffix,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        prefixText: prefix,
        suffixText: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiskonTypeButton extends StatelessWidget {
  const _DiskonTypeButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceContainerHighest,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          size: 22,
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
