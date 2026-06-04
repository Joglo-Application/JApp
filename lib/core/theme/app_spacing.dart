import 'package:flutter/material.dart';

/// Spacing scale for the Resto POS design system.
///
/// Base unit: 4 dp.  All values are multiples of the base unit.
///
/// Three surfaces are exposed:
///   [AppSpacing]       — raw `double` values (SizedBox, gap, etc.)
///   [AppInsets]        — pre-built `EdgeInsets` for common padding patterns
///   [AppBreakpoint]    — layout-grid constants (margins, gutters, sidebar width)
abstract final class AppSpacing {
  // ── Scale ─────────────────────────────────────────────────────────────────

  /// 4 dp — icon internal padding, tight inline gaps.
  static const double x1 = 4;

  /// 8 dp — between icon and label, chip internal horizontal padding.
  static const double x2 = 8;

  /// 12 dp — card internal vertical rhythm, list item row gaps.
  static const double x3 = 12;

  /// 16 dp — card padding (default), section inner padding.
  static const double x4 = 16;

  /// 20 dp — page horizontal margin (phone).
  static const double x5 = 20;

  /// 24 dp — between sections on a page.
  static const double x6 = 24;

  /// 32 dp — panel padding (tablet sidebar).
  static const double x8 = 32;

  /// 40 dp — hero section top padding.
  static const double x10 = 40;

  /// 48 dp — large section separators.
  static const double x12 = 48;

  /// 64 dp — full-bleed panel top offset.
  static const double x16 = 64;
}

/// Pre-built [EdgeInsets] for the most common padding patterns.
///
/// Prefer these over ad-hoc `EdgeInsets.all(AppSpacing.x4)` calls so that
/// padding intent is named and changes propagate from one place.
abstract final class AppInsets {
  /// Card interior padding — 16 dp all sides.
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.x4);

  /// Card interior padding with tighter vertical — 12 v / 16 h.
  static const EdgeInsets cardCompact = EdgeInsets.symmetric(
    horizontal: AppSpacing.x4,
    vertical: AppSpacing.x3,
  );

  /// Page scroll padding — 20 h / 24 v (phone).
  static const EdgeInsets pageMobile = EdgeInsets.symmetric(
    horizontal: AppSpacing.x5,
    vertical: AppSpacing.x6,
  );

  /// Page scroll padding — 24 all sides (tablet content panel).
  static const EdgeInsets pageTablet = EdgeInsets.all(AppSpacing.x6);

  /// Sidebar / order panel inner padding — 32 dp all sides.
  static const EdgeInsets panel = EdgeInsets.all(AppSpacing.x8);

  /// Chip internal padding — 8 h / 4 v.
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: AppSpacing.x2,
    vertical: AppSpacing.x1,
  );

  /// Button internal padding — 16 h / 12 v (supplements minimum size from theme).
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: AppSpacing.x4,
    vertical: AppSpacing.x3,
  );

  /// List tile content padding — 16 h / 8 v.
  static const EdgeInsets listTile = EdgeInsets.symmetric(
    horizontal: AppSpacing.x4,
    vertical: AppSpacing.x2,
  );

  /// Section header spacing — 24 top / 12 bottom.
  static const EdgeInsets sectionHeader = EdgeInsets.only(
    top: AppSpacing.x6,
    bottom: AppSpacing.x3,
  );

  /// Bottom sheet interior padding — 32 h / 24 v.
  static const EdgeInsets bottomSheet = EdgeInsets.symmetric(
    horizontal: AppSpacing.x8,
    vertical: AppSpacing.x6,
  );

  /// Dialog interior padding — 24 all sides.
  static const EdgeInsets dialog = EdgeInsets.all(AppSpacing.x6);
}

/// Layout-grid constants derived from the design system breakpoints.
abstract final class AppBreakpoint {
  // ── Breakpoint widths ─────────────────────────────────────────────────────

  /// Compact → medium transition (phone upper bound).
  static const double medium = 600;

  /// Medium → expanded transition (tablet lower bound).
  static const double expanded = 1024;

  // ── Phone grid (360–599 dp) ───────────────────────────────────────────────

  static const int phoneColumns = 4;
  static const double phoneGutter = AppSpacing.x2; // 8 dp
  static const double phoneMargin = AppSpacing.x4; // 16 dp

  // ── Tablet grid (1024 dp+) ────────────────────────────────────────────────

  static const int tabletColumns = 12;
  static const double tabletGutter = AppSpacing.x4; // 16 dp
  static const double tabletMargin = AppSpacing.x6; // 24 dp

  /// Fixed width of the order-summary sidebar (tablet landscape).
  static const double sidebarWidth = 360;

  // ── Convenience ───────────────────────────────────────────────────────────

  /// Returns `true` when [width] is in the expanded (tablet) range.
  static bool isExpanded(double width) => width >= expanded;

  /// Returns `true` when [width] is in the compact (phone) range.
  static bool isCompact(double width) => width < medium;
}
