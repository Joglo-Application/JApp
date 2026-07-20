import 'package:flutter/material.dart';

import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

/// Dialog PIN Supervisor. PIN diverifikasi ke server (`POST /auth/verify-pin`),
/// bukan dicocokkan di klien.
///
/// Mengembalikan PIN yang sudah terverifikasi, atau `null` bila dibatalkan.
/// PIN-nya ikut dikembalikan karena sebagian aksi (mis. retur transaksi)
/// perlu menyertakannya lagi saat memanggil API.
///
/// Usage:
/// ```dart
/// final pin = await showDialog<String>(
///   context: context,
///   builder: (_) => const PinSupervisorDialog(),
/// );
/// if (pin == null) return; // dibatalkan
/// ```
class PinSupervisorDialog extends StatefulWidget {
  const PinSupervisorDialog({super.key});

  @override
  State<PinSupervisorDialog> createState() => _PinSupervisorDialogState();
}

class _PinSupervisorDialogState extends State<PinSupervisorDialog> {
  String _pin = '';
  bool _wrongPin = false;
  bool _memeriksa = false;
  String _pesanError = 'PIN salah, coba lagi';

  static const _maxLength = 6;

  void _onKey(String key) {
    // Abaikan penekanan tombol selama menunggu jawaban server.
    if (_memeriksa) return;

    setState(() {
      _wrongPin = false;
      if (key == '↻') {
        _pin = '';
      } else if (key == 'C') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (_pin.length < _maxLength) {
        _pin += key;
      }
    });

    if (_pin.length == _maxLength) _verifikasi();
  }

  Future<void> _verifikasi() async {
    setState(() => _memeriksa = true);
    final client = ApiClient.instance;
    final pin = _pin;
    try {
      await client.dio.post<Map<String, dynamic>>(
        '/auth/verify-pin',
        data: {'pin': pin},
      );
      if (mounted) Navigator.of(context).pop(pin);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pin = '';
        _wrongPin = true;
        _pesanError = client.toApiException(e).message;
        _memeriksa = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.35,
        vertical: AppSpacing.x4,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key_rounded,
                        color: AppColors.onPrimary, size: 22),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        'PIN Supervisor',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Batal',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // PIN display
            ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x6,
                  vertical: AppSpacing.x8,
                ),
                child: Column(
                  children: [
                    if (_wrongPin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                        child: Text(
                          _pesanError,
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_maxLength, (i) {
                        final filled = i < _pin.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.x3),
                          child: filled
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : Container(
                                  width: 28,
                                  height: 2,
                                  color: AppColors.primary,
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Numpad
            ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                      ['↻', '0', 'C'],
                    ]) ...[
                      Row(
                        children: row.map((key) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: key == row.first ? 0 : AppSpacing.x3,
                                bottom: row == ['↻', '0', 'C']
                                    ? 0
                                    : AppSpacing.x3,
                              ),
                              child: _PinKey(
                                label: key,
                                onTap: () => _onKey(key),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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

class _PinKey extends StatelessWidget {
  const _PinKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIcon = label == '↻';
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: AspectRatio(
          aspectRatio: 1.6,
          child: Center(
            child: isIcon
                ? const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 26)
                : Text(
                    label,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
