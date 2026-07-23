import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Halaman ambil foto memakai kamera perangkat — termasuk webcam di desktop
/// web (lewat getUserMedia). Di-`pop` dengan [XFile] hasil jepretan, atau
/// `null` bila pengguna membatalkan.
class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _index = 0;
  bool _initializing = true;
  bool _capturing = false;
  String? _error;
  String? _errorDetail;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _error = 'Tidak ada kamera yang terdeteksi.';
        });
        return;
      }
      await _initController(_index);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Tidak bisa mengakses kamera. Pastikan izin diberikan.';
        _errorDetail = e.toString();
      });
    }
  }

  void _retry() {
    setState(() {
      _initializing = true;
      _error = null;
      _errorDetail = null;
    });
    _setup();
  }

  Future<void> _fallbackGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;
    Navigator.of(context).pop(file);
  }

  Future<void> _initController(int index) async {
    final old = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    await old?.dispose();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _index = index;
      _initializing = false;
      _error = null;
    });
  }

  Future<void> _flip() async {
    if (_cameras.length < 2) return;
    setState(() => _initializing = true);
    await _initController((_index + 1) % _cameras.length);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(file);
    } catch (_) {
      if (!mounted) return;
      setState(() => _capturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil foto, coba lagi')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildBody()),
            Positioned(
              top: AppSpacing.x2,
              left: AppSpacing.x2,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                iconSize: 28,
              ),
            ),
            if (_error == null && !_initializing)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.x6,
                child: _buildControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_rounded,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.x4),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              if (_errorDetail != null) ...[
                const SizedBox(height: AppSpacing.x2),
                Text(
                  _errorDetail!,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.x5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ErrorBtn(
                    label: 'Coba Lagi',
                    filled: false,
                    onTap: _retry,
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  _ErrorBtn(
                    label: 'Pilih dari Galeri',
                    filled: true,
                    onTap: _fallbackGallery,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Center(child: CameraPreview(_controller!));
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _capture,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.primary, width: 4),
            ),
            child: _capturing
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(Icons.camera_alt_rounded, color: Colors.black),
          ),
        ),
        if (_cameras.length > 1) ...[
          const SizedBox(width: AppSpacing.x6),
          IconButton(
            onPressed: _flip,
            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
            iconSize: 30,
          ),
        ],
      ],
    );
  }
}

class _ErrorBtn extends StatelessWidget {
  const _ErrorBtn({
    required this.label,
    required this.filled,
    required this.onTap,
  });
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : Colors.transparent,
      borderRadius: AppRadius.sm,
      shape: filled
          ? null
          : RoundedRectangleBorder(
              borderRadius: AppRadius.sm,
              side: const BorderSide(color: Colors.white54),
            ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: filled ? AppColors.onPrimary : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
