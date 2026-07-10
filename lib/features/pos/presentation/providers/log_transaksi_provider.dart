import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/log_transaksi_repository_impl.dart';
import '../../domain/entities/log_transaksi_entry.dart';
import '../../domain/repositories/log_transaksi_repository.dart';

class LogTransaksiProvider extends ChangeNotifier {
  LogTransaksiProvider({LogTransaksiRepository? repository})
      : _repository = repository ?? LogTransaksiRepositoryImpl();

  final LogTransaksiRepository _repository;

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

  Future<void> load({DateTime? date}) async {
    _selectedDate = date ?? _selectedDate;
    _tipeFilter = null;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _repository.fetchLogs(date: _selectedDate);
    } on ApiException catch (e) {
      _error = e.message;
      _entries = const [];
    } catch (_) {
      _error = 'Gagal memuat log transaksi.';
      _entries = const [];
    }
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
