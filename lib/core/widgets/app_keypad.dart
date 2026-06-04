import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A generic 3 × 4 numeric keypad.
///
/// Reports every key tap via [onKeyTap] as a plain string:
///   - Digit keys → `"0"` – `"9"`
///   - Decimal key → `"."`  (only shown when [hasDecimal] is true)
///   - Backspace  → `"⌫"`
///
/// The widget is intentionally stateless — the parent owns the input string
/// and formats / constrains it as needed for its domain (currency, quantity, etc.).
///
/// ```dart
/// AppKeypad(
///   onKeyTap: (key) {
///     if (key == '⌫') {
///       _removeLastChar();
///     } else {
///       _append(key);
///     }
///   },
/// )
/// ```
class AppKeypad extends StatelessWidget {
  const AppKeypad({
    super.key,
    required this.onKeyTap,
    this.hasDecimal = true,
    this.keyAspectRatio = 2.0,
  });

  /// Called with the tapped key string.
  final ValueChanged<String> onKeyTap;

  /// Whether to show the decimal point key. Default: true.
  final bool hasDecimal;

  /// Width-to-height ratio of each key cell. Default: 2.0.
  final double keyAspectRatio;

  static const _backspace = '⌫';

  static const List<String> _keys = [
    '7', '8', '9',
    '4', '5', '6',
    '1', '2', '3',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Rows 1–3: 7 8 9 / 4 5 6 / 1 2 3 ──────────────────────────────
        for (int row = 0; row < 3; row++) ...[
          if (row > 0) const SizedBox(height: AppSpacing.x2),
          Row(
            children: List.generate(3, (col) {
              final key = _keys[row * 3 + col];
              return _buildCell(
                child: _KeyButton(
                  label: key,
                  onTap: () => onKeyTap(key),
                  aspectRatio: keyAspectRatio,
                ),
                col: col,
              );
            }),
          ),
        ],
        const SizedBox(height: AppSpacing.x2),
        // ── Row 4: . / 0 / ⌫ ─────────────────────────────────────────────
        Row(
          children: [
            _buildCell(
              child: hasDecimal
                  ? _KeyButton(
                      label: '.',
                      onTap: () => onKeyTap('.'),
                      aspectRatio: keyAspectRatio,
                    )
                  : const SizedBox.expand(),
              col: 0,
            ),
            _buildCell(
              child: _KeyButton(
                label: '0',
                onTap: () => onKeyTap('0'),
                aspectRatio: keyAspectRatio,
              ),
              col: 1,
            ),
            _buildCell(
              child: _BackspaceButton(
                onTap: () => onKeyTap(_backspace),
                aspectRatio: keyAspectRatio,
              ),
              col: 2,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCell({required Widget child, required int col}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: col == 0 ? 0 : AppSpacing.x2),
        child: child,
      ),
    );
  }
}

// ── Private key widgets ───────────────────────────────────────────────────────

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.onTap,
    required this.aspectRatio,
  });

  final String label;
  final VoidCallback onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.sm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.sm,
          child: Center(
            child: Text(
              label,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  const _BackspaceButton({
    required this.onTap,
    required this.aspectRatio,
  });

  final VoidCallback onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.sm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.sm,
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 20,
              color: AppColors.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}
