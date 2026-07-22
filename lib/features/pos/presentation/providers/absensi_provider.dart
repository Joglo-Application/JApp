import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/absensi_saya_remote_datasource.dart';

enum AbsensiStatus { belumHadir, sudahHadir, sudahPulang }

class AbsensiRecord {
  const AbsensiRecord({required this.waktu, required this.type});
  final DateTime waktu;
  final AbsensiStatus type;
}

/// Absensi milik karyawan yang sedang login. Status & riwayat berasal dari
/// server (`GET /absensi/me`); tombol Hadir/Pulang mengirim ke server
/// (`POST /absensi/masuk` & `/keluar`) sehingga terbaca supervisor & owner.
class AbsensiProvider extends ChangeNotifier {
  AbsensiProvider({AbsensiSayaRemoteDatasource? datasource})
      : _ds = datasource ?? AbsensiSayaRemoteDatasourceImpl();

  final AbsensiSayaRemoteDatasource _ds;

  AbsensiStatus _status = AbsensiStatus.belumHadir;
  DateTime? _waktuHadir;
  DateTime? _waktuPulang;
  List<AbsensiRecord> _history = const [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  AbsensiStatus get status => _status;
  DateTime? get waktuHadir => _waktuHadir;
  DateTime? get waktuPulang => _waktuPulang;
  List<AbsensiRecord> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  void _apply(AbsensiSaya s) {
    _status = s.sudahKeluar
        ? AbsensiStatus.sudahPulang
        : s.sudahMasuk
            ? AbsensiStatus.sudahHadir
            : AbsensiStatus.belumHadir;
    _waktuHadir = s.jamMasuk;
    _waktuPulang = s.jamKeluar;
    // Tiap hari riwayat dipecah jadi baris Hadir (jam masuk) dan — bila ada —
    // baris Pulang (jam keluar), sesuai tampilan sheet Riwayat.
    _history = [
      for (final r in s.riwayat) ...[
        AbsensiRecord(waktu: r.jamMasuk, type: AbsensiStatus.sudahHadir),
        if (r.jamKeluar != null)
          AbsensiRecord(waktu: r.jamKeluar!, type: AbsensiStatus.sudahPulang),
      ],
    ];
  }

  /// Muat status hari ini + riwayat dari server.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _apply(await _ds.fetchSaya());
    } catch (_) {
      // Biarkan state default agar halaman tetap bisa dipakai untuk absen.
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Absen masuk. Mengembalikan `true` bila berhasil; pesan gagal ada di [error].
  Future<bool> hadir() => _kirim(_ds.absenMasuk);

  /// Absen keluar. Mengembalikan `true` bila berhasil.
  Future<bool> pulang() => _kirim(_ds.absenKeluar);

  Future<bool> _kirim(Future<void> Function() aksi) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await aksi();
      _apply(await _ds.fetchSaya());
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
