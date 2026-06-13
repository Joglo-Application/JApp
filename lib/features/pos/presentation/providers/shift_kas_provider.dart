import 'package:flutter/material.dart';

enum ShiftKasJenis { setoran, penarikan }

class ShiftKasEntry {
  const ShiftKasEntry({
    required this.id,
    required this.jenis,
    required this.namaTransaksi,
    required this.jumlah,
    required this.waktu,
    this.catatan = '',
  });

  final String id;
  final ShiftKasJenis jenis;
  final String namaTransaksi;
  final String catatan;
  final double jumlah;
  final DateTime waktu;
}

class ShiftKasProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  double _kasAwal = 0;
  DateTime? _shiftStartTime;
  double get kasAwal => _kasAwal;
  DateTime? get shiftStartTime => _shiftStartTime;
  bool get shiftStarted => _shiftStartTime != null;

  final List<ShiftKasEntry> _entries = [];
  List<ShiftKasEntry> get entries => List.unmodifiable(_entries);

  ShiftKasEntry? _selected;
  ShiftKasEntry? get selected => _selected;

  double get totalKeluar => _entries
      .where((e) => e.jenis == ShiftKasJenis.penarikan)
      .fold(0.0, (s, e) => s + e.jumlah);

  double get totalKas => _kasAwal + _entries.fold(
        0.0,
        (sum, e) =>
            e.jenis == ShiftKasJenis.setoran ? sum + e.jumlah : sum - e.jumlah,
      );

  void mulaiShift(double kasAwal) {
    _kasAwal = kasAwal;
    _shiftStartTime = DateTime.now();
    notifyListeners();
  }

  void changeDate(DateTime date) {
    _selectedDate = date;
    _selected = null;
    notifyListeners();
  }

  void select(ShiftKasEntry entry) {
    _selected = entry;
    notifyListeners();
  }

  void clearSelection() {
    _selected = null;
    notifyListeners();
  }

  void addEntry({
    required ShiftKasJenis jenis,
    required String namaTransaksi,
    required double jumlah,
    String catatan = '',
  }) {
    _entries.add(ShiftKasEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jenis: jenis,
      namaTransaksi: namaTransaksi,
      catatan: catatan,
      jumlah: jumlah,
      waktu: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateEntry(
    String id, {
    required String namaTransaksi,
    required double jumlah,
    String catatan = '',
  }) {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final old = _entries[idx];
    _entries[idx] = ShiftKasEntry(
      id: old.id,
      jenis: old.jenis,
      namaTransaksi: namaTransaksi,
      catatan: catatan,
      jumlah: jumlah,
      waktu: old.waktu,
    );
    notifyListeners();
  }

  void berakhirShift() {
    _kasAwal = 0;
    _shiftStartTime = null;
    _entries.clear();
    _selected = null;
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    if (_selected?.id == id) _selected = null;
    notifyListeners();
  }
}
