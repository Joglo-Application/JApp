import 'package:flutter/foundation.dart';

import '../../domain/entities/log_transaksi_entry.dart';

class LogTransaksiProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<LogTransaksiEntry> _entries = const [];
  DateTime _selectedDate = DateTime.now();
  String? _tipeFilter;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  String? get tipeFilter => _tipeFilter;

  Set<String> get availableTipes =>
      _entries.map((e) => e.tipe).toSet();

  List<LogTransaksiEntry> get filtered {
    if (_tipeFilter == null) return List.unmodifiable(_entries);
    return _entries.where((e) => e.tipe == _tipeFilter).toList();
  }

  // TODO: replace with actual repository/use-case call when API is ready
  Future<void> load({DateTime? date}) async {
    _selectedDate = date ?? _selectedDate;
    _tipeFilter = null;
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));
    _entries = const [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeDate(DateTime date) async {
    if (_isSameDay(date, _selectedDate)) return;
    await load(date: date);
  }

  void setTipeFilter(String? tipe) {
    if (_tipeFilter == tipe) return;
    _tipeFilter = tipe;
    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
