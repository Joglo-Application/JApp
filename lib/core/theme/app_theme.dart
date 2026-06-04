import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Assembles the single [ThemeData] for the Resto POS app.
///
/// Usage in MaterialApp:
///   theme: AppTheme.light
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.scheme,
        textTheme: AppTypography.textTheme,

        // ── AppBar ────────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.shellBackground,
          foregroundColor: AppColors.onShell,
          elevation: 4,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppColors.onShell, size: 24),
          titleTextStyle: AppTypography.textTheme.headlineLarge?.copyWith(
            color: AppColors.onShell,
          ),
        ),

        // ── Card ──────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          elevation: 3,
          shape: AppRadius.toShape(AppRadius.md),
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
        ),

        // ── Input ─────────────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.xs,
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.xs,
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.xs,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.xs,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.xs,
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.error,
          ),
        ),

        // ── ElevatedButton ────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
            minimumSize: const Size(88, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
        ),

        // ── FilledButton (confirm / checkout / add-to-cart) ───────────────
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.tertiary,
            foregroundColor: AppColors.onTertiary,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
            minimumSize: const Size(88, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
        ),

        // ── OutlinedButton (cancel / secondary actions) ───────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.onSurface,
            side: const BorderSide(color: AppColors.outline),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
            minimumSize: const Size(88, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
        ),

        // ── TextButton ────────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(48, 40),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
        ),

        // ── Dialog ────────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          elevation: 5,
          shape: AppRadius.toShape(AppRadius.lg),
          backgroundColor: AppColors.surface,
          titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
          ),
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),

        // ── BottomSheet ───────────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.topLg),
        ),

        // ── NavigationBar ─────────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryContainer,
          height: 64,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return AppTypography.textTheme.labelMedium?.copyWith(
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            );
          }),
        ),

        // ── Chip ──────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          labelStyle: AppTypography.textTheme.labelMedium,
          backgroundColor: AppColors.surfaceContainerHighest,
          selectedColor: AppColors.primaryContainer,
          labelPadding: EdgeInsets.zero,
        ),

        // ── Divider ───────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.outlineVariant,
          thickness: 1,
          space: 0,
        ),

        // ── SnackBar ──────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: AppRadius.toShape(AppRadius.md),
          backgroundColor: AppColors.secondary,
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSecondary,
          ),
        ),

        // ── ListTile ──────────────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // ── Icon ──────────────────────────────────────────────────────────
        iconTheme: const IconThemeData(
          size: 24,
          color: AppColors.onSurfaceVariant,
        ),
      );
}
