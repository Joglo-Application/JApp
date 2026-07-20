import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/transaksi_repository_impl.dart';
import '../../domain/entities/transaksi.dart';
import '../../domain/repositories/transaksi_repository.dart';
import '../../domain/usecases/fetch_transaksi_usecase.dart';

class TransaksiProvider extends ChangeNotifier {
  TransaksiProvider({TransaksiRepository? repository}) {
    _repository = repository ?? TransaksiRepositoryImpl();
    _fetchTransaksi = FetchTransaksiUseCase(_repository);
  }

  late final TransaksiRepository _repository;
  late final FetchTransaksiUseCase _fetchTransaksi;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;
  List<Transaksi> _all = const [];
  Transaksi? _selected;
  String? _paymentTypeFilter;
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();

  // Weekly dashboard data
  List<(DateTime, double)> _weeklyPenjualan = const [];
  List<(DateTime, int)> _weeklyGuest = const [];
  bool _isLoadingWeekly = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  Transaksi? get selected => _selected;
  String? get paymentTypeFilter => _paymentTypeFilter;
  String get searchQuery => _searchQuery;
  DateTime get selectedDate => _selectedDate;
  bool get isLoadingWeekly => _isLoadingWeekly;

  Set<String> get availablePaymentTypes =>
      _all.map((t) => t.tipePembayaran).toSet();

  List<Transaksi> get filtered {
    final query = _searchQuery.trim().toLowerCase();
    return _all.where((t) {
      if (_paymentTypeFilter != null && t.tipePembayaran != _paymentTypeFilter) {
        return false;
      }
      if (query.isNotEmpty && !t.kode.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Dashboard aggregates (computed from current day's data) ───────────────

  double get totalPenjualan =>
      _all.where((t) => !t.isReturned).fold(0.0, (s, t) => s + t.total);

  int get totalGuest => _all.where((t) => !t.isReturned).length;

  int get totalItemQty => _all
      .where((t) => !t.isReturned)
      .fold(0, (s, t) => s + t.items.fold(0, (si, i) => si + i.qty));

  List<(String, int)> get topProdukByQty {
    final counts = <String, int>{};
    for (final t in _all.where((t) => !t.isReturned)) {
      for (final item in t.items) {
        counts[item.nama] = (counts[item.nama] ?? 0) + item.qty;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => (e.key, e.value)).toList();
  }

  List<(DateTime, double)> get weeklyPenjualan =>
      List.unmodifiable(_weeklyPenjualan);

  List<(DateTime, int)> get weeklyGuest =>
      List.unmodifiable(_weeklyGuest);

  List<Transaksi> get all => List.unmodifiable(_all);

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
    _weeklyPenjualan = const [];
    _weeklyGuest = const [];
    notifyListeners();
    await Future.wait([load(), loadWeeklyData()]);
  }

  /// Selects a day WITHIN the already-loaded week (from the date panel).
  /// Reloads only that day's transactions and keeps the weekly list stable, so
  /// the panel doesn't flicker or reshuffle the clicked date to the bottom.
  Future<void> selectDate(DateTime date) async {
    if (_isSameDay(date, _selectedDate)) return;
    _selectedDate = date;
    _selected = null;
    _all = const [];
    notifyListeners();
    await load();
  }

  Future<void> loadWeeklyData() async {
    if (_isLoadingWeekly) return;
    _isLoadingWeekly = true;
    notifyListeners();

    try {
      final base = _selectedDate;
      final results = await Future.wait(
        List.generate(
          7,
          (i) => _fetchTransaksi(date: base.subtract(Duration(days: 6 - i))),
        ),
      );

      _weeklyPenjualan = List.generate(7, (i) {
        final date = base.subtract(Duration(days: 6 - i));
        final total = results[i]
            .where((t) => !t.isReturned)
            .fold(0.0, (s, t) => s + t.total);
        return (date, total);
      });

      _weeklyGuest = List.generate(7, (i) {
        final date = base.subtract(Duration(days: 6 - i));
        return (date, results[i].where((t) => !t.isReturned).length);
      });
    } catch (_) {
      _weeklyPenjualan = const [];
      _weeklyGuest = const [];
    } finally {
      _isLoadingWeekly = false;
      notifyListeners();
    }
  }

  void select(Transaksi? transaksi) {
    if (_selected == transaksi) return;
    _selected = transaksi;
    notifyListeners();
  }

  /// Meretur transaksi di server, lalu menandainya di state lokal bila
  /// berhasil. Sebelumnya penandaan hanya lokal sehingga hilang saat data
  /// dimuat ulang, stok tidak kembali, dan kas tidak disesuaikan.
  ///
  /// Mengembalikan pesan galat bila gagal, atau `null` bila berhasil.
  Future<String?> returTransaksi({
    required String kode,
    required String alasan,
    required String pin,
  }) async {
    try {
      await _repository.returTransaksi(kode: kode, alasan: alasan, pin: pin);
    } on ApiException catch (e) {
      return e.message;
    }

    _all = _all
        .map((t) => t.kode == kode ? t.copyWith(isReturned: true) : t)
        .toList();
    if (_selected?.kode == kode) {
      _selected = _all.firstWhere((t) => t.kode == kode);
    }
    notifyListeners();
    return null;
  }

  void setPaymentTypeFilter(String? type) {
    if (_paymentTypeFilter == type) return;
    _paymentTypeFilter = type;
    _selected = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    // Lepas seleksi hanya jika transaksinya ikut tersaring keluar.
    if (_selected != null && !filtered.contains(_selected)) {
      _selected = null;
    }
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
