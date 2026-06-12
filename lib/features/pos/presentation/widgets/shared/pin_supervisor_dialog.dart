import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

/// Shows a PIN Supervisor dialog and returns `true` when the correct PIN is
/// entered, or `false` / `null` when cancelled.
///
/// Usage:
/// ```dart
/// final ok = await showDialog<bool>(
///   context: context,
///   builder: (_) => const PinSupervisorDialog(),
/// );
/// ```
class PinSupervisorDialog extends StatefulWidget {
  const PinSupervisorDialog({super.key});

  @override
  State<PinSupervisorDialog> createState() => _PinSupervisorDialogState();
}

class _PinSupervisorDialogState extends State<PinSupervisorDialog> {
  String _pin = '';
  bool _wrongPin = false;

  static const _correctPin = '123456';
  static const _maxLength = 6;

  void _onKey(String key) {
    setState(() {
      _wrongPin = false;
      if (key == '↻') {
        _pin = '';
      } else if (key == 'C') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (_pin.length < _maxLength) {
        _pin += key;
        if (_pin.length == _maxLength) {
          if (_pin == _correctPin) {
            Navigator.of(context).pop(true);
          } else {
            _pin = '';
            _wrongPin = true;
          }
        }
      }
    });
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
                      onPressed: () => Navigator.of(context).pop(false),
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
                          'PIN salah, coba lagi',
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
