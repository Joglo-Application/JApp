import 'package:flutter/material.dart';

enum ShiftKasJenis { setoran, penarikan }

class ShiftKasEntry {
  const ShiftKasEntry({
    required this.id,
    required this.jenis,
    required this.keterangan,
    required this.jumlah,
    required this.waktu,
  });

  final String id;
  final ShiftKasJenis jenis;
  final String keterangan;
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
    required String keterangan,
    required double jumlah,
  }) {
    _entries.add(ShiftKasEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jenis: jenis,
      keterangan: keterangan,
      jumlah: jumlah,
      waktu: DateTime.now(),
    ));
    notifyListeners();
  }
}
