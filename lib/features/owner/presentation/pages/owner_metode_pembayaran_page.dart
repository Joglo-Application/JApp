import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/datasources/metode_pembayaran_remote_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'owner_tambah_metode_pembayaran_page.dart';

class OwnerMetodePembayaranPage extends StatefulWidget {
  const OwnerMetodePembayaranPage({super.key});

  @override
  State<OwnerMetodePembayaranPage> createState() =>
      _OwnerMetodePembayaranPageState();
}

class _OwnerMetodePembayaranPageState extends State<OwnerMetodePembayaranPage> {
  final _datasource = MetodePembayaranRemoteDatasource();
  final List<_MetodeData> _metodes = [];
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final rows = await _datasource.fetch();
      if (!mounted) return;
      setState(() {
        _metodes
          ..clear()
          ..addAll(
            rows.map(
              (r) => _MetodeData(
                metodeId: r.metodeId,
                nama: r.nama,
                // TUNAI tidak boleh dihapus: selalu ada jalur bayar tunai.
                isDeletable: r.kode != 'cash',
              ),
            ),
          );
      });
    } on ApiException {
      // Biarkan kosong daripada menampilkan metode contoh.
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x4,
              ),
              child: Row(
                children: [
                  Text(
                    'Metode Pembayaran',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  _TambahButton(onTap: _onTambah),
                ],
              ),
            ),
            Expanded(
              child: _memuat
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x4,
                      ),
                      itemCount: _metodes.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.x3),
                      itemBuilder: (_, i) => _MetodeItem(
                        metode: _metodes[i],
                        onDelete: _metodes[i].isDeletable
                            ? () => _onDelete(i)
                            : null,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Metode Pembayaran',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: AppRadius.full,
            child: const Icon(Icons.close_rounded, size: 24),
          ),
        ],
      ),
    );
  }

  Future<void> _onDelete(int index) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _datasource.delete(_metodes[index].metodeId);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    await _muat();
  }

  Future<void> _onTambah() async {
    final result = await context.push<TambahMetodePembayaranResult>(
      AppRoutes.ownerTambahMetodePembayaran,
    );
    if (result == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _datasource.create(
        nama: result.nama,
        kode: MetodePembayaranRemoteDatasource.tebakKode(result.nama),
        urutan: _metodes.length,
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    await _muat();
  }
}

class _TambahButton extends StatelessWidget {
  const _TambahButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                color: AppColors.onPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.x1),
              Text(
                'Tambah',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetodeData {
  const _MetodeData({
    required this.metodeId,
    required this.nama,
    this.isDeletable = true,
  });

  final int metodeId;
  final String nama;
  final bool isDeletable;
}

class _MetodeItem extends StatelessWidget {
  const _MetodeItem({required this.metode, required this.onDelete});

  final _MetodeData metode;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.md,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                metode.nama,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: metode.isDeletable
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
