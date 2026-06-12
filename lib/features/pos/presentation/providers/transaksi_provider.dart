import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/transaksi_repository_impl.dart';
import '../../domain/entities/transaksi.dart';
import '../../domain/repositories/transaksi_repository.dart';
import '../../domain/usecases/fetch_transaksi_usecase.dart';

class TransaksiProvider extends ChangeNotifier {
  TransaksiProvider({TransaksiRepository? repository}) {
    final repo = repository ?? TransaksiRepositoryImpl();
    _fetchTransaksi = FetchTransaksiUseCase(repo);
  }

  late final FetchTransaksiUseCase _fetchTransaksi;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;
  List<Transaksi> _all = const [];
  Transaksi? _selected;
  String? _paymentTypeFilter;
  DateTime _selectedDate = DateTime.now();

  // ── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  Transaksi? get selected => _selected;
  String? get paymentTypeFilter => _paymentTypeFilter;
  DateTime get selectedDate => _selectedDate;

  Set<String> get availablePaymentTypes =>
      _all.map((t) => t.tipePembayaran).toSet();

  List<Transaksi> get filtered {
    return _all.where((t) {
      if (_paymentTypeFilter != null && t.tipePembayaran != _paymentTypeFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _fetchTransaksi(date: _selectedDate);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Gagal memuat transaksi. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeDate(DateTime date) async {
    if (_isSameDay(date, _selectedDate)) return;
    _selectedDate = date;
    _selected = null;
    _all = const [];
    notifyListeners();
    await load();
  }

  void select(Transaksi? transaksi) {
    if (_selected == transaksi) return;
    _selected = transaksi;
    notifyListeners();
  }

  void markAsReturned(String kode) {
    _all = _all
        .map((t) => t.kode == kode ? t.copyWith(isReturned: true) : t)
        .toList();
    if (_selected?.kode == kode) {
      _selected = _all.firstWhere((t) => t.kode == kode);
    }
    notifyListeners();
  }

  void setPaymentTypeFilter(String? type) {
    if (_paymentTypeFilter == type) return;
    _paymentTypeFilter = type;
    _selected = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
