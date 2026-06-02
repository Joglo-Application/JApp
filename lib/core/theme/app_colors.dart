import 'package:flutter/material.dart';

/// Single source of truth for all colors in the Resto POS design system.
///
/// Structure:
///   - [_Palette] — raw hex primitives (private, never used directly in widgets)
///   - [AppColors] — semantic aliases + the [ColorScheme] factory
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = _Palette.brandGold;
  static const Color onPrimary = _Palette.white;
  static const Color primaryContainer = _Palette.brandGoldLight;
  static const Color onPrimaryContainer = _Palette.brandGoldDark;

  // ── Secondary (dark shell) ────────────────────────────────────────────────
  static const Color secondary = _Palette.surfaceDark;
  static const Color onSecondary = _Palette.white;
  static const Color secondaryContainer = _Palette.surfaceMid;
  static const Color onSecondaryContainer = _Palette.white;

  // ── Tertiary (success / confirm) ──────────────────────────────────────────
  static const Color tertiary = _Palette.success;
  static const Color onTertiary = _Palette.white;
  static const Color tertiaryContainer = _Palette.successContainer;
  static const Color onTertiaryContainer = _Palette.successDark;

  // ── Error (danger / cancel) ──────────────────────────────────────────────
  static const Color error = _Palette.danger;
  static const Color onError = _Palette.white;
  static const Color errorContainer = _Palette.dangerContainer;
  static const Color onErrorContainer = _Palette.dangerDark;

  // ── Surface ───────────────────────────────────────────────────────────────
  static const Color surface = _Palette.white;
  static const Color onSurface = _Palette.inkDark;
  static const Color surfaceContainerHighest = _Palette.surfaceTint;
  static const Color onSurfaceVariant = _Palette.inkMuted;

  // ── Background ────────────────────────────────────────────────────────────
  static const Color background = _Palette.surfaceTint;
  static const Color onBackground = _Palette.inkDark;

  // ── Outline ───────────────────────────────────────────────────────────────
  static const Color outline = _Palette.outlineDefault;
  static const Color outlineVariant = _Palette.outlineSubtle;

  // ── Semantic extras (for direct widget use) ───────────────────────────────
  static const Color warning = _Palette.warning;
  static const Color warningContainer = _Palette.warningContainer;
  static const Color onWarning = _Palette.white;
  static const Color onWarningContainer = _Palette.warningDark;

  /// Scrim over media — product-card unavailable overlay.
  static const Color scrim = Color(0x80000000);

  /// Star rating fill color.
  static const Color starFill = _Palette.brandGold;

  /// Star rating empty color.
  static const Color starEmpty = _Palette.outlineDefault;

  // ── Shell surfaces (used by AppShellHeader & OrderSummaryPanel) ───────────
  static const Color shellBackground = _Palette.surfaceDark;
  static const Color shellSurface = _Palette.surfaceMid;
  static const Color onShell = _Palette.white;

  // ── ColorScheme ───────────────────────────────────────────────────────────
  static ColorScheme get scheme => const ColorScheme(
        brightness: Brightness.light,
        // Primary
        primary: _Palette.brandGold,
        onPrimary: _Palette.white,
        primaryContainer: _Palette.brandGoldLight,
        onPrimaryContainer: _Palette.brandGoldDark,
        // Secondary
        secondary: _Palette.surfaceDark,
        onSecondary: _Palette.white,
        secondaryContainer: _Palette.surfaceMid,
        onSecondaryContainer: _Palette.white,
        // Tertiary
        tertiary: _Palette.success,
        onTertiary: _Palette.white,
        tertiaryContainer: _Palette.successContainer,
        onTertiaryContainer: _Palette.successDark,
        // Error
        error: _Palette.danger,
        onError: _Palette.white,
        errorContainer: _Palette.dangerContainer,
        onErrorContainer: _Palette.dangerDark,
        // Surface
        surface: _Palette.white,
        onSurface: _Palette.inkDark,
        surfaceContainerHighest: _Palette.surfaceTint,
        onSurfaceVariant: _Palette.inkMuted,
        // Outline
        outline: _Palette.outlineDefault,
        outlineVariant: _Palette.outlineSubtle,
        // Scrim / shadow
        scrim: Color(0xFF000000),
      );
}

/// Raw hex primitives — private to this file.
/// Widgets must reference [AppColors] semantic names, never this class.
abstract final class _Palette {
  // Brand
  static const Color brandGold = Color(0xFFC9A62B);
  static const Color brandGoldLight = Color(0xFFF5E199);
  static const Color brandGoldDark = Color(0xFF8E7210);

  // Shell / panel surfaces
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color surfaceMid = Color(0xFF2E2E3E);
  static const Color surfaceTint = Color(0xFFF5F5F0);
  static const Color white = Color(0xFFFFFFFF);

  // Ink (text / icons on surfaces)
  static const Color inkDark = Color(0xFF1A1A1A);
  static const Color inkMuted = Color(0xFF6B6B6B);

  // Semantic: success
  static const Color success = Color(0xFF2E9E4F);
  static const Color successContainer = Color(0xFFD4EDDA);
  static const Color successDark = Color(0xFF1A6B32);

  // Semantic: danger
  static const Color danger = Color(0xFFD93025);
  static const Color dangerContainer = Color(0xFFFDECEA);
  static const Color dangerDark = Color(0xFF8B1A12);

  // Semantic: warning
  static const Color warning = Color(0xFFE8900A);
  static const Color warningContainer = Color(0xFFFFF3CD);
  static const Color warningDark = Color(0xFF7A4A00);

  // Outline
  static const Color outlineDefault = Color(0xFFE0E0E0);
  static const Color outlineSubtle = Color(0xFFF0F0F0);
}
