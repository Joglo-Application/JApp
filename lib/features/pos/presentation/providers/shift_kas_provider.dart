import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/shift_kas_remote_datasource.dart';
import '../../data/models/shift_kas_model.dart';
import '../../domain/entities/shift_kas_entry.dart';

// Re-export agar halaman yang meng-import provider tetap mendapat tipe ini.
export '../../domain/entities/shift_kas_entry.dart';

class ShiftKasProvider extends ChangeNotifier {
  ShiftKasProvider({ShiftKasRemoteDatasource? datasource})
      : _ds = datasource ?? ShiftKasRemoteDatasourceImpl();

  final ShiftKasRemoteDatasource _ds;

  ShiftKasModel? _shift;
  DateTime _selectedDate = DateTime.now();
  ShiftKasEntry? _selected;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // ── Getters (kompatibel dengan halaman) ─────────────────────────────────────
  DateTime get selectedDate => _selectedDate;
  bool get shiftStarted => _shift?.isOpen ?? false;

  /// Apakah pada tanggal terpilih sudah ada kas (shift), apa pun statusnya.
  /// Dipakai tombol "+": belum ada → dialog Kas Awal; sudah ada → masuk/keluar.
  bool get hasShift => _shift != null;
  double get kasAwal => (_shift?.kasAwal ?? 0).toDouble();
  DateTime? get shiftStartTime => _shift?.waktuMulai;
  double get totalKeluar => (_shift?.totalKeluar ?? 0).toDouble();
  double get totalKas => (_shift?.totalKas ?? 0).toDouble();
  List<ShiftKasEntry> get entries =>
      List.unmodifiable(_shift?.entries ?? const <ShiftKasEntry>[]);
  ShiftKasEntry? get selected => _selected;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  // ── Load ────────────────────────────────────────────────────────────────────
  /// Muat kas untuk hari ini (dipanggil saat halaman dibuka). Memakai tanggal —
  /// bukan shift aktif lintas hari — agar data yang tampil selalu sesuai tanggal
  /// yang ditunjukkan; hari tanpa kas tampil kosong.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedDate = DateTime.now();
      _setShift(await _ds.fetchByDate(_selectedDate));
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat shift.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeDate(DateTime date) async {
    _selectedDate = date;
    _selected = null;
    _isLoading = true;
    notifyListeners();
    try {
      _setShift(await _ds.fetchByDate(date));
    } catch (_) {
      _setShift(null);
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Aksi (mutasi via API, lalu refresh dari respons) ────────────────────────
  Future<void> mulaiShift(double kasAwal) =>
      _run(() => _ds.startShift(kasAwal.round()));

  Future<void> addEntry({
    required ShiftKasJenis jenis,
    required String namaTransaksi,
    required double jumlah,
    String catatan = '',
    String? lampiranUrl,
  }) {
    final id = _shift?.shiftId;
    if (id == null) return Future.value();
    return _run(() => _ds.addEntry(
          id,
          jenis: jenis,
          namaTransaksi: namaTransaksi,
          jumlah: jumlah.round(),
          catatan: catatan.isEmpty ? null : catatan,
          lampiranUrl: lampiranUrl,
        ));
  }

  /// Unggah lampiran; kembalikan URL relatif, atau null bila gagal ([error]
  /// berisi pesannya).
  Future<String?> uploadLampiran(List<int> bytes, String filename) async {
    try {
      return await _ds.uploadLampiran(bytes, filename);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _error = 'Gagal mengunggah lampiran.';
      notifyListeners();
      return null;
    }
  }

  Future<void> updateEntry(
    String id, {
    required String namaTransaksi,
    required double jumlah,
    String catatan = '',
  }) {
    final entryId = int.tryParse(id);
    if (entryId == null) return Future.value();
    return _run(() => _ds.updateEntry(
          entryId,
          namaTransaksi: namaTransaksi,
          jumlah: jumlah.round(),
          catatan: catatan.isEmpty ? null : catatan,
        ));
  }

  Future<void> deleteEntry(String id) {
    final entryId = int.tryParse(id);
    if (entryId == null) return Future.value();
    return _run(() => _ds.deleteEntry(entryId));
  }

  /// Tutup shift (bila nanti ada tombolnya di UI).
  Future<void> berakhirShift() {
    final id = _shift?.shiftId;
    if (id == null) return Future.value();
    return _run(() => _ds.closeShift(id));
  }

  // ── Selection (state UI lokal) ──────────────────────────────────────────────
  void select(ShiftKasEntry entry) {
    _selected = entry;
    notifyListeners();
  }

  void clearSelection() {
    _selected = null;
    notifyListeners();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Future<void> _run(Future<ShiftKasModel> Function() action) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      _setShift(await action());
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Operasi shift kas gagal.';
    }
    _isSubmitting = false;
    notifyListeners();
  }

  void _setShift(ShiftKasModel? shift) {
    _shift = shift;
    // Sinkronkan entri terpilih dengan objek baru (identity berubah tiap reload).
    if (_selected != null) {
      final id = _selected!.id;
      final matches = shift?.entries.where((e) => e.id == id).toList();
      _selected = (matches != null && matches.isNotEmpty) ? matches.first : null;
    }
  }
}
