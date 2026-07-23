import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'camera_capture_page.dart';

/// Menampilkan pilihan sumber foto (kamera / galeri). Bila kamera dipilih,
/// pengguna diminta persetujuan lebih dulu. Mengembalikan foto terpilih, atau
/// `null` bila dibatalkan pada tahap mana pun.
Future<XFile?> pickFotoFromSource(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.topLg),
    builder: (_) => const _SourcePickerSheet(),
  );
  if (source == null || !context.mounted) return null;

  // Persetujuan pengguna sebelum kamera dibuka.
  if (source == ImageSource.camera) {
    final approved = await _showCameraApprovalDialog(context);
    if (approved != true || !context.mounted) return null;

    // Web (termasuk desktop): image_picker tidak bisa membuka webcam, jadi
    // pakai halaman kamera khusus (getUserMedia via package `camera`).
    // Mobile/native tetap memakai kamera bawaan lewat image_picker.
    if (kIsWeb) {
      return Navigator.of(context).push<XFile>(
        MaterialPageRoute(builder: (_) => const CameraCapturePage()),
      );
    }
  }

  final picker = ImagePicker();
  return picker.pickImage(source: source);
}

// ── Bottom sheet: pilih sumber ────────────────────────────────────────────────

class _SourcePickerSheet extends StatelessWidget {
  const _SourcePickerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.x3),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: AppRadius.full,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilih Sumber Foto',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _SourceTile(
            icon: Icons.photo_camera_outlined,
            label: 'Kamera',
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: 'Galeri',
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          const SizedBox(height: AppSpacing.x3),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: AppSpacing.x4),
            Text(label, style: AppTypography.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

// ── Dialog: persetujuan kamera ────────────────────────────────────────────────

Future<bool?> _showCameraApprovalDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.surface,
      shape: AppRadius.toShape(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.onPrimary,
                size: 34,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Izinkan Kamera',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Aplikasi akan membuka kamera untuk mengambil foto.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x5),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Batal',
                    color: AppColors.outline,
                    textColor: AppColors.onSurface,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.x3),
                Expanded(
                  child: _DialogBtn(
                    label: 'Izinkan',
                    color: AppColors.primary,
                    textColor: AppColors.onPrimary,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _DialogBtn extends StatelessWidget {
  const _DialogBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.sm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
          child: Center(
            child: Text(
              label,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
