import 'package:flutter/material.dart';

/// Border-radius scale for the Resto POS design system.
///
/// Two surfaces are exposed per token:
///   [AppRadius]       — `BorderRadius` values for BoxDecoration / Container
///   [AppRadiusValue]  — raw `Radius` values for ClipRRect or individual corners
///
/// Shape helpers:
///   [AppRadius.toShape]  — wraps a [BorderRadius] in [RoundedRectangleBorder]
///                          for use with Material component `shape` properties
abstract final class AppRadius {
  // ── BorderRadius ──────────────────────────────────────────────────────────

  /// 4 dp — input fields, table cells, small tags.
  static const BorderRadius xs = BorderRadius.all(_RadiusValue.xs);

  /// 8 dp — buttons, quantity controls.
  static const BorderRadius sm = BorderRadius.all(_RadiusValue.sm);

  /// 12 dp — product cards, cart item rows, stat cards.
  static const BorderRadius md = BorderRadius.all(_RadiusValue.md);

  /// 16 dp — bottom sheets, modals, panel containers.
  static const BorderRadius lg = BorderRadius.all(_RadiusValue.lg);

  /// 24 dp — hero image containers, large dialog sheets.
  static const BorderRadius xl = BorderRadius.all(_RadiusValue.xl);

  /// 999 dp — category chips, badge pills, FABs.
  static const BorderRadius full = BorderRadius.all(_RadiusValue.full);

  // ── Bottom-sheet helpers (top corners only) ────────────────────────────────

  /// [lg] applied only to top corners — for bottom sheets.
  static const BorderRadius topLg = BorderRadius.only(
    topLeft: _RadiusValue.lg,
    topRight: _RadiusValue.lg,
  );

  /// [xl] applied only to top corners — for large modal sheets.
  static const BorderRadius topXl = BorderRadius.only(
    topLeft: _RadiusValue.xl,
    topRight: _RadiusValue.xl,
  );

  // ── Card image clip (top corners only) ────────────────────────────────────

  /// [md] applied only to top corners — for product card image ClipRRect.
  static const BorderRadius topMd = BorderRadius.only(
    topLeft: _RadiusValue.md,
    topRight: _RadiusValue.md,
  );

  // ── Shape factory ─────────────────────────────────────────────────────────

  /// Wraps [borderRadius] in a [RoundedRectangleBorder].
  ///
  /// Use for Material component `shape` properties, e.g.:
  ///   Card(shape: AppRadius.toShape(AppRadius.md))
  static RoundedRectangleBorder toShape(
    BorderRadius borderRadius, {
    BorderSide side = BorderSide.none,
  }) =>
      RoundedRectangleBorder(borderRadius: borderRadius, side: side);
}

/// Raw [Radius] values — use when a single [Radius] is required (e.g. ClipRRect
/// with a uniform corner, or composing custom [BorderRadius.only] values).
abstract final class AppRadiusValue {
  static const Radius xs = _RadiusValue.xs;
  static const Radius sm = _RadiusValue.sm;
  static const Radius md = _RadiusValue.md;
  static const Radius lg = _RadiusValue.lg;
  static const Radius xl = _RadiusValue.xl;
  static const Radius full = _RadiusValue.full;
}

/// Private primitive Radius constants — single source of truth for dp values.
abstract final class _RadiusValue {
  static const Radius xs = Radius.circular(4);
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius xl = Radius.circular(24);
  static const Radius full = Radius.circular(999);
}
