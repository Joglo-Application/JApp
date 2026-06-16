import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/pengaturan/pengaturan_form_widgets.dart';

// Placeholder model — swap with real entity + provider when backend is wired.
class _TokoData {
  const _TokoData({
    required this.namaToko,
    required this.telepon,
    required this.email,
    required this.alamat,
    required this.negara,
    required this.provinsi,
    required this.kota,
    required this.kecamatan,
    required this.kodePos,
    required this.lat,
    required this.lng,
  });

  final String namaToko;
  final String telepon;
  final String email;
  final String alamat;
  final String negara;
  final String provinsi;
  final String kota;
  final String kecamatan;
  final String kodePos;
  final double lat;
  final double lng;
}

const _defaultData = _TokoData(
  namaToko: 'Wedangan Joglo Sumput',
  telepon: '082275641556',
  email: 'Wedangan123@gmail.com',
  alamat:
      'Depan Lapangan Bola, Jl. Balai 08, RW.03, Sumput, Kec. Sidoarjo, Kabupaten Sidoarjo, Jawa Timur 61228',
  negara: 'Indonesia',
  provinsi: 'Jawa Timur',
  kota: 'Kabupaten Sidoarjo',
  kecamatan: 'Sumput',
  kodePos: '61228',
  lat: -7.4558,
  lng: 112.7183,
);

class OwnerPengaturanTokoPage extends StatelessWidget {
  const OwnerPengaturanTokoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            PengaturanDetailTopBar(
              title: 'Toko',
              onSave: () => Navigator.of(context).pop(),
              onClose: () => Navigator.of(context).pop(),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
            const Expanded(
              child: _TokoBody(data: _defaultData),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scrollable body ───────────────────────────────────────────────────────────

class _TokoBody extends StatelessWidget {
  const _TokoBody({required this.data});

  final _TokoData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PengaturanSectionHeader(label: 'Profil Toko'),
          const SizedBox(height: AppSpacing.x3),
          _FormGroup(
            children: [
              _FormRow(label: 'Nama Toko', value: data.namaToko, onTap: () {}),
              _FormRow(label: 'Telepon', value: data.telepon, onTap: () {}),
              _FormRow(label: 'Email', value: data.email, onTap: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.x5),
          PengaturanSectionHeader(label: 'Alamat Toko'),
          const SizedBox(height: AppSpacing.x3),
          _MapTile(lat: data.lat, lng: data.lng),
          const SizedBox(height: AppSpacing.x3),
          _FormGroup(
            children: [
              _FormRow(label: 'Alamat', value: data.alamat, onTap: () {}),
              _FormRow(label: 'Negara', value: data.negara, onTap: () {}),
              _FormRow(label: 'Provinsi', value: data.provinsi, onTap: () {}),
              _FormRow(label: 'Kota', value: data.kota, onTap: () {}),
              _FormRow(label: 'Kecamatan', value: data.kecamatan, onTap: () {}),
              _FormRow(label: 'Kode Pos', value: data.kodePos, onTap: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.x8),
        ],
      ),
    );
  }
}

// ── Form group (rows stacked with dividers) ───────────────────────────────────

class _FormGroup extends StatelessWidget {
  const _FormGroup({required this.children});

  final List<_FormRow> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.x3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.x3),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.outlineVariant,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Form row ──────────────────────────────────────────────────────────────────

class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: AppSpacing.x4),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map tile ──────────────────────────────────────────────────────────────────

class _MapTile extends StatelessWidget {
  const _MapTile({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(lat, lng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.x3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(AppSpacing.x3),
        ),
        child: SizedBox(
          height: 220,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.resto_pos',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.error,
                      size: 36,
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
}
