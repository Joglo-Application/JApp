import 'package:flutter/material.dart';

/// Typography system for the Resto POS design system.
///
/// Font: Inter · Base: 14 sp · Scale: Material 3
///
/// Usage:
///   Theme.of(context).textTheme  — for standard M3 styles via ThemeData
///   AppTypography.price          — for semantic one-off styles
abstract final class AppTypography {
  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = ['Roboto', 'sans-serif'];

  // ── TextTheme ─────────────────────────────────────────────────────────────

  static TextTheme get textTheme => const TextTheme(
        // Display — defined for completeness; not used in this app
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 1.12, // 64 / 57
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 1.16, // 52 / 45
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 1.22, // 44 / 36
          letterSpacing: 0,
        ),

        // Headline — shell header, section titles, cart totals
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.25, // 40 / 32
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.29, // 36 / 28
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.33, // 32 / 24
          letterSpacing: 0,
        ),

        // Title — panel headings, product names, cart item labels
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.27, // 28 / 22
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.50, // 24 / 16
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43, // 20 / 14
          letterSpacing: 0.1,
        ),

        // Label — buttons, chips, badges, rating counts
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43, // 20 / 14
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33, // 16 / 12
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.45, // 16 / 11
          letterSpacing: 0.5,
        ),

        // Body — descriptions, list text, helper text
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.50, // 24 / 16
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43, // 20 / 14
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33, // 16 / 12
          letterSpacing: 0.4,
        ),
      );

  // ── Semantic styles ───────────────────────────────────────────────────────
  // Use these for roles that don't map 1-to-1 to an M3 slot.
  // Color is intentionally omitted — apply via widget or copyWith.

  /// Product / cart item price — titleLarge bold.
  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.27,
    letterSpacing: 0,
  );

  /// Struck-through original price alongside a discount.
  static const TextStyle priceStrikethrough = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    decoration: TextDecoration.lineThrough,
  );

  /// Digit inside a quantity stepper control.
  static const TextStyle quantity = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 0.15,
  );

  /// Currency symbol baseline-aligned with [price].
  static const TextStyle currencySymbol = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );
}
