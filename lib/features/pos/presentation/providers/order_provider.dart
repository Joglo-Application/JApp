import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/meja_remote_datasource.dart';
import '../../data/datasources/pajak_setting_datasource.dart';
import '../../data/models/loaded_pesanan_model.dart';
import '../../data/repositories/checkout_repository_impl.dart';
import '../../data/repositories/log_transaksi_repository_impl.dart';
import '../../domain/entities/create_pesanan_params.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/pembayaran.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/repositories/log_transaksi_repository.dart';
import '../../domain/usecases/cancel_pesanan_usecase.dart';
import '../../domain/usecases/create_pembayaran_usecase.dart';
import '../../domain/usecases/create_pesanan_usecase.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    CheckoutRepository? checkoutRepository,
    MejaRemoteDatasource? mejaDatasource,
    LogTransaksiRepository? logRepository,
    TarifSettingDatasource? tarifDatasource,
  }) {
    final repo = checkoutRepository ?? CheckoutRepositoryImpl();
    _createPesanan = CreatePesananUseCase(repo);
    _createPembayaran = CreatePembayaranUseCase(repo);
    _cancelPesanan = CancelPesananUseCase(repo);
    _mejaDatasource = mejaDatasource ?? MejaRemoteDatasourceImpl();
    _logRepo = logRepository ?? LogTransaksiRepositoryImpl();
    _tarifDatasource = tarifDatasource ?? TarifSettingDatasourceImpl();
  }

  late final CreatePesananUseCase _createPesanan;
  late final CreatePembayaranUseCase _createPembayaran;
  late final CancelPesananUseCase _cancelPesanan;
  late final MejaRemoteDatasource _mejaDatasource;
  late final LogTransaksiRepository _logRepo;
  late final TarifSettingDatasource _tarifDatasource;

  // Kode sesi audit-log untuk order berjalan (dibuat lazily, direset saat clear).
  String? _kodeTransaksi;

  // Tarif toko (Pajak & Biaya Layanan) — default terpersist di server (grup
  // pengaturan `pajak`). Dimuat via [loadTarifSetting] saat POS dibuka, diubah
  // lewat [savePajakSetting] / [saveLayananSetting] (ketuk baris terkait → PIN
  // supervisor). Nilai berlaku untuk semua pesanan.
  DiscountType _pajakType = DiscountType.percent;

  /// Angka persen (mis. 10) bila [_pajakType] percent, atau nominal Rupiah
  /// (mis. 5000) bila amount.
  double _pajakValue = 5;
  bool _pajakAktif = true;

  DiscountType _layananType = DiscountType.percent;
  double _layananValue = 5;
  bool _layananAktif = true;

  final List<OrderItem> _items = [];
  String _customerName = '';
  int? _memberPoints;

  /// Id member terpilih. Tanpa ini pesanan tersimpan tanpa kaitan member,
  /// sehingga riwayat transaksi member selalu kosong.
  int? _memberId;
  double _orderDiscount = 0;
  DiscountType _orderDiscountType = DiscountType.amount;
  String? _orderPromoName;
  String _orderNote = '';
  OrderType? _orderType;
  int? _mejaId;
  String? _mejaNomor;
  int? _redeemedPointCost;
  double _redeemDiscount = 0;
  DiscountType _redeemDiscountType = DiscountType.amount;
  String? _redeemRewardName;
  String? _redeemedItemId;
  double? _redeemDisplayValue;

  // ── Checkout (kirim dapur → bayar) ─────────────────────────────────────────
  int? _pesananId;
  double? _serverTotal;
  bool _isSubmitting = false;
  String? _submitError;

  /// True once the order has been created on the backend ("Kirim Dapur").
  bool get isSentToKitchen => _pesananId != null;
  int? get pesananId => _pesananId;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  /// Authoritative total returned by the server after creating the order;
  /// falls back to the locally computed [total] before that.
  double get payableTotal => _serverTotal ?? total;

  String get customerName => _customerName;
  int? get memberPoints => _memberPoints;
  int? get memberId => _memberId;
  double get orderDiscount => _orderDiscount;
  DiscountType get orderDiscountType => _orderDiscountType;
  String? get orderPromoName => _orderPromoName;
  String get orderNote => _orderNote;
  OrderType? get orderType => _orderType;
  int? get mejaId => _mejaId;
  String? get mejaNomor => _mejaNomor;
  int? get redeemedPointCost => _redeemedPointCost;
  String? get redeemRewardName => _redeemRewardName;
  String? get redeemedItemId => _redeemedItemId;

  double get redeemDiscountAmount {
    if (_redeemDiscount <= 0) return 0;
    if (_redeemDiscountType == DiscountType.percent) {
      return subtotal * (_redeemDiscount / 100);
    }
    return _redeemDiscount;
  }

  // For free-item rewards this holds the item's unit price (informational display).
  // For discount rewards it falls back to the computed discount amount.
  double get redeemDisplayValue => _redeemDisplayValue ?? redeemDiscountAmount;

  void setOrderNote(String note) {
    _orderNote = note;
    notifyListeners();
  }

  void setOrderType(OrderType type) {
    _orderType = type;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    _memberPoints = null;
    _memberId = null;
    notifyListeners();
  }

  void setMember(String name, int points, {int? memberId}) {
    _customerName = name;
    _memberPoints = points;
    _memberId = memberId;
    notifyListeners();
  }

  /// Meja terpilih dari halaman Pilih Meja (dikirim sebagai mejaId di pesanan).
  /// Memilih meja menyiratkan Dine-In (kecuali channel online sudah dipilih).
  void setMeja(int id, String nomor) {
    _mejaId = id;
    _mejaNomor = nomor;
    if (_orderType == null || _orderType == OrderType.takeAway) {
      _orderType = OrderType.dineIn;
    }
    notifyListeners();
  }

  /// Tipe order efektif untuk ditampilkan: default Take-Away bila kasir belum
  /// memilih In/Away (meja → Dine-In via [setMeja]).
  OrderType get effectiveOrderType => _orderType ?? OrderType.takeAway;

  /// Memuat pesanan pending yang sudah ada (lewat "Lihat Pesanan" di meja) ke
  /// POS agar bisa langsung dibayar. Status menjadi "sudah dikirim ke dapur",
  /// dan total memakai nilai dari server.
  void loadExistingOrder(LoadedPesanan p) {
    _items
      ..clear()
      ..addAll(p.items.map((it) => OrderItem(
            productId: it.menuId?.toString() ?? 'custom-${it.detailId}',
            name: it.nama,
            unitPrice: it.hargaSatuan.toDouble(),
            quantity: it.jumlah,
            discount: it.diskon.toDouble(),
            note: it.catatan ?? '',
          )));
    _pesananId = p.pesananId;
    _serverTotal = p.total.toDouble();
    _mejaId = p.mejaId;
    _customerName = p.customerNama ?? '';
    _orderType = _orderTypeFromApi(p.orderType);
    // Reset state transien agar tidak salah hitung (total memakai _serverTotal).
    _orderDiscount = 0;
    _orderPromoName = null;
    _orderNote = '';
    _memberPoints = null;
    _memberId = null;
    _submitError = null;
    notifyListeners();
  }

  OrderType? _orderTypeFromApi(String? s) => switch (s) {
        'dine_in' => OrderType.dineIn,
        'take_away' => OrderType.takeAway,
        'gofood' => OrderType.goFood,
        'grabfood' => OrderType.grabFood,
        'shopeefood' => OrderType.shopeeFood,
        _ => null,
      };

  void setOrderDiscount(double discount, DiscountType type, {String? promoName}) {
    final oldVal = _orderDiscount;
    final oldType = _orderDiscountType;
    _orderDiscount = discount;
    _orderDiscountType = type;
    _orderPromoName = promoName;
    if (discount > 0) {
      final tipe = type == DiscountType.percent ? 'DISC_PCT' : 'DISC_AMT';
      _log(tipe, '${_fmtDisc(oldVal, oldType)} -> ${_fmtDisc(discount, type)} (pesanan)');
    }
    notifyListeners();
  }

  UnmodifiableListView<OrderItem> get items => UnmodifiableListView(_items);

  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  int get totalQty => _items.fold(0, (s, i) => s + i.quantity);

  // Free-item reward is excluded from subtotal so taxes are not inflated.
  double get subtotal => _items
      .where((i) => i.productId != _redeemedItemId)
      .fold(0.0, (s, i) => s + i.subtotal);
  /// Tipe & nilai Pajak toko (untuk menampilkan label "Pajak").
  DiscountType get pajakType => _pajakType;
  double get pajakValue => _pajakValue;

  /// Tipe & nilai Biaya Layanan toko (untuk menampilkan label "Biaya Layanan").
  DiscountType get layananType => _layananType;
  double get layananValue => _layananValue;

  /// Nominal biaya layanan: persen dari subtotal, atau nominal Rupiah tetap.
  double get serviceAmount => !_layananAktif
      ? 0
      : _layananType == DiscountType.percent
          ? subtotal * (_layananValue / 100)
          : _layananValue;

  /// Nominal pajak: persen dari subtotal, atau nominal Rupiah tetap. Nol bila
  /// pajak dinonaktifkan di pengaturan.
  double get pajakAmount => !_pajakAktif
      ? 0
      : _pajakType == DiscountType.percent
          ? subtotal * (_pajakValue / 100)
          : _pajakValue;

  // "Pajak" untuk perhitungan total = biaya layanan + pajak (keduanya server
  // menghitung terpisah, tapi total-nya sama).
  double get taxAmount => serviceAmount + pajakAmount;

  /// Muat default Pajak & Biaya Layanan toko dari server (dipanggil saat POS
  /// dibuka). Best-effort: bila gagal, tetap pakai nilai terakhir/awal.
  Future<void> loadTarifSetting() async {
    try {
      final s = await _tarifDatasource.fetch();
      _pajakType = s.pajak.tipe;
      _pajakValue = s.pajak.nilai;
      _pajakAktif = s.pajak.aktif;
      _layananType = s.layanan.tipe;
      _layananValue = s.layanan.nilai;
      _layananAktif = s.layanan.aktif;
      notifyListeners();
    } catch (_) {
      // Abaikan; POS tetap jalan dengan nilai default.
    }
  }

  /// Ubah default Pajak toko (ketuk "Pajak" + PIN supervisor).
  Future<bool> savePajakSetting(DiscountType type, double value, String pin) =>
      _saveTarif(
        target: 'pajak',
        type: type,
        value: value,
        pin: pin,
        oldDesc: _pajakDesc,
        apply: (s) {
          _pajakType = s.pajak.tipe;
          _pajakValue = s.pajak.nilai;
          _pajakAktif = s.pajak.aktif;
        },
      );

  /// Ubah default Biaya Layanan toko (ketuk "Biaya Layanan" + PIN supervisor).
  Future<bool> saveLayananSetting(DiscountType type, double value, String pin) =>
      _saveTarif(
        target: 'layanan',
        type: type,
        value: value,
        pin: pin,
        oldDesc: _layananDesc,
        apply: (s) {
          _layananType = s.layanan.tipe;
          _layananValue = s.layanan.nilai;
          _layananAktif = s.layanan.aktif;
        },
      );

  /// Persist satu tarif ([target] = 'pajak' | 'layanan') ke server lalu berlaku
  /// untuk semua pesanan berikutnya. [value] = angka persen (percent) atau
  /// nominal Rupiah (amount).
  Future<bool> _saveTarif({
    required String target,
    required DiscountType type,
    required double value,
    required String pin,
    required String Function() oldDesc,
    required void Function(TarifSetting) apply,
  }) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();
    try {
      final old = oldDesc();
      final s = await _tarifDatasource.update(
        target: target,
        tipe: type,
        nilai: value < 0 ? 0 : value,
        pin: pin,
      );
      apply(s);
      _log('UPDATE_TAX', '$old -> ${oldDesc()}');
      return true;
    } on ApiException catch (e) {
      _submitError = e.message;
      return false;
    } catch (_) {
      _submitError = 'Gagal memperbarui tarif.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String _pajakDesc() => _pajakType == DiscountType.percent
      ? '${_pajakValue.toStringAsFixed(0)}%'
      : 'Rp ${_pajakValue.toStringAsFixed(0)}';

  String _layananDesc() => _layananType == DiscountType.percent
      ? '${_layananValue.toStringAsFixed(0)}%'
      : 'Rp ${_layananValue.toStringAsFixed(0)}';

  double get orderDiscountAmount {
    if (_orderDiscount <= 0) return 0;
    if (_orderDiscountType == DiscountType.percent) {
      return subtotal * (_orderDiscount / 100);
    }
    return _orderDiscount;
  }

  double get total => subtotal + taxAmount - orderDiscountAmount - redeemDiscountAmount;

  int get earnedPoints => (subtotal / 2000).floor();

  void _clearRedemptionState() {
    if (_redeemedItemId != null) {
      _items.removeWhere((e) => e.productId == _redeemedItemId);
      _redeemedItemId = null;
    }
    _redeemedPointCost = null;
    _redeemDiscount = 0;
    _redeemDiscountType = DiscountType.amount;
    _redeemRewardName = null;
    _redeemDisplayValue = null;
  }

  void redeemReward(String name, int pointCost, double discount, DiscountType type) {
    if (_memberPoints == null) return;
    if (_redeemedPointCost != null) {
      _memberPoints = _memberPoints! + _redeemedPointCost!;
    }
    _clearRedemptionState();
    _redeemedPointCost = pointCost;
    _redeemDiscount = discount;
    _redeemDiscountType = type;
    _redeemRewardName = name;
    _memberPoints = _memberPoints! - pointCost;
    notifyListeners();
  }

  void redeemFreeItem({
    required String name,
    required int pointCost,
    required OrderItem item,
    required double displayValue,
  }) {
    if (_memberPoints == null) return;
    if (_redeemedPointCost != null) {
      _memberPoints = _memberPoints! + _redeemedPointCost!;
    }
    _clearRedemptionState();
    _redeemedPointCost = pointCost;
    _redeemRewardName = name;
    _redeemDisplayValue = displayValue;
    _redeemedItemId = item.productId;
    _memberPoints = _memberPoints! - pointCost;
    _items.add(item);
    notifyListeners();
  }

  void removeRedemption() {
    if (_redeemedPointCost == null) return;
    _memberPoints = (_memberPoints ?? 0) + _redeemedPointCost!;
    _clearRedemptionState();
    notifyListeners();
  }

  // ── Audit log POS (fire-and-forget; tak boleh mengganggu alur POS) ──────────
  String _ensureKode() =>
      _kodeTransaksi ??= 'POS-${DateTime.now().millisecondsSinceEpoch}';

  static String _labelFor(String tipe) => switch (tipe) {
        'ADD_QTY' || 'REDUCE_QTY' => 'Update jumlah item',
        'VOID_ITEM' => 'Hapus item',
        'DISC_AMT' || 'DISC_AMT_ITEM' => 'Update jumlah diskon',
        'DISC_PCT' || 'DISC_PCT_ITEM' => 'Update persen diskon',
        'UPDATE_PRICE' => 'Update harga',
        'UPDATE_TAX' => 'Update pajak',
        'SEND_KITCHEN' => 'Kirim ke dapur',
        _ => '',
      };

  static String _fmtDisc(double v, DiscountType t) => t == DiscountType.percent
      ? '${v.toStringAsFixed(0)}%'
      : v.toStringAsFixed(0);

  void _log(String tipe, String change) {
    final label = _labelFor(tipe);
    unawaited(
      _logRepo
          .createLog(
            tipe: tipe,
            kodeTransaksi: _ensureKode(),
            deskripsi: label.isEmpty ? change : '$change\n$label',
          )
          .catchError((_) {}),
    );
  }

  void addOrIncrement(OrderItem item) {
    final idx = _items.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      final old = _items[idx].quantity;
      _items[idx] = _items[idx].copyWith(quantity: old + 1);
      _log('ADD_QTY', '$old -> ${old + 1}, ${item.name}');
    } else {
      _items.add(item);
      _log('ADD_QTY', '0 -> ${item.quantity}, ${item.name}');
    }
    notifyListeners();
  }

  void addFromForm(OrderItem item) {
    final idx = _items.indexWhere((e) => e.productId == item.productId);
    final oldQty = idx >= 0 ? _items[idx].quantity : 0;
    final oldDisc = idx >= 0 ? _items[idx].discount : 0.0;
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        quantity: oldQty + item.quantity,
        discount: item.discount,
        discountType: item.discountType,
        note: item.note,
      );
    } else {
      _items.add(item);
    }
    _log('ADD_QTY', '$oldQty -> ${oldQty + item.quantity}, ${item.name}');
    if (item.discount > 0 && item.discount != oldDisc) {
      final tipe =
          item.discountType == DiscountType.percent ? 'DISC_PCT_ITEM' : 'DISC_AMT_ITEM';
      _log(tipe,
          '${_fmtDisc(oldDisc, item.discountType)} -> ${_fmtDisc(item.discount, item.discountType)}, ${item.quantity}x ${item.name}');
    }
    notifyListeners();
  }

  void increment(String productId) {
    final idx = _items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    final old = _items[idx].quantity;
    _items[idx] = _items[idx].copyWith(quantity: old + 1);
    _log('ADD_QTY', '$old -> ${old + 1}, ${_items[idx].name}');
    notifyListeners();
  }

  void decrement(String productId) {
    final idx = _items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    final item = _items[idx];
    if (item.quantity <= 1) {
      _items.removeAt(idx);
      _log('VOID_ITEM', '${item.name} dihapus');
    } else {
      _items[idx] = item.copyWith(quantity: item.quantity - 1);
      _log('REDUCE_QTY', '${item.quantity} -> ${item.quantity - 1}, ${item.name}');
    }
    notifyListeners();
  }

  void replaceItem(OrderItem item) {
    final idx = _items.indexWhere((e) => e.productId == item.productId);
    if (idx < 0) return;
    final old = _items[idx];
    _items[idx] = item;
    // Log perubahan qty saat edit item lewat form.
    if (item.quantity != old.quantity) {
      final tipe = item.quantity > old.quantity ? 'ADD_QTY' : 'REDUCE_QTY';
      _log(tipe, '${old.quantity} -> ${item.quantity}, ${item.name}');
    }
    // Log perubahan diskon item.
    if ((item.discount != old.discount ||
            item.discountType != old.discountType) &&
        (item.discount > 0 || old.discount > 0)) {
      final tipe = item.discountType == DiscountType.percent
          ? 'DISC_PCT_ITEM'
          : 'DISC_AMT_ITEM';
      _log(tipe,
          '${_fmtDisc(old.discount, old.discountType)} -> ${_fmtDisc(item.discount, item.discountType)}, ${item.quantity}x ${item.name}');
    }
    // Log perubahan harga satuan.
    if (item.unitPrice != old.unitPrice) {
      _log('UPDATE_PRICE',
          '${old.unitPrice.toStringAsFixed(0)} -> ${item.unitPrice.toStringAsFixed(0)}, ${item.name}');
    }
    notifyListeners();
  }

  void remove(String productId) {
    if (productId == _redeemedItemId) {
      _memberPoints = (_memberPoints ?? 0) + (_redeemedPointCost ?? 0);
      _clearRedemptionState();
    } else {
      final idx = _items.indexWhere((e) => e.productId == productId);
      final name = idx >= 0 ? _items[idx].name : '';
      _items.removeWhere((e) => e.productId == productId);
      if (name.isNotEmpty) _log('VOID_ITEM', '$name dihapus');
    }
    notifyListeners();
  }

  // ── Checkout ───────────────────────────────────────────────────────────────

  /// Creates the order on the backend ("Kirim Dapur"): `POST /pesanan`.
  /// Stock is deducted and totals computed server-side. Returns `true` on
  /// success; on failure see [submitError].
  Future<bool> kirimDapur() async {
    if (_items.isEmpty || _isSubmitting || isSentToKitchen) return false;
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();
    try {
      final totalItem = totalQty;
      final pesanan = await _createPesanan(_buildPesananParams());
      _pesananId = pesanan.pesananId;
      _serverTotal = pesanan.total;
      _log('SEND_KITCHEN', 'Kirim $totalItem item ke dapur');
      return true;
    } on ApiException catch (e) {
      _submitError = e.message;
      return false;
    } catch (_) {
      _submitError = 'Gagal mengirim pesanan ke dapur.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Menyimpan cart saat ini sebagai draft "held" (fitur Pending / tombol "+").
  /// `POST /pesanan` dengan `hold:true` — tanpa potong stok / ke dapur.
  Future<bool> holdOrder(String customerNama) async {
    if (_items.isEmpty || _isSubmitting) return false;
    _isSubmitting = true;
    _submitError = null;
    _customerName = customerNama;
    notifyListeners();
    try {
      await _createPesanan(_buildPesananParams(hold: true));
      return true;
    } on ApiException catch (e) {
      _submitError = e.message;
      return false;
    } catch (_) {
      _submitError = 'Gagal menyimpan pesanan pending.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Auto-simpan cart yang sedang diisi ke Pending saat kasir meninggalkan POS
  /// (efeknya sama seperti tombol "+", tapi dipicu oleh perpindahan menu supaya
  /// pesanan yang belum sempat disimpan tidak hilang).
  ///
  /// No-op bila cart kosong, sedang ada proses simpan, atau pesanan sudah
  /// dikirim ke dapur (sudah tersimpan di server). [holdOrder] menyalin isi cart
  /// secara sinkron sebelum `await` pertamanya, jadi memanggil [clear] tepat
  /// setelahnya aman — payload yang dikirim tetap utuh. Mengembalikan `true`
  /// bila draft benar-benar disimpan.
  Future<bool> autoHoldToPending() {
    if (_items.isEmpty || _isSubmitting || isSentToKitchen) {
      return Future.value(false);
    }
    final saving = holdOrder(_customerName);
    clear();
    return saving;
  }

  /// Menyimpan SEBAGIAN item (subset) sebagai draft held — dipakai Split Bill.
  /// Tidak menyentuh cart aktif (pemanggil yang menghapus item terpilih).
  Future<bool> holdItems(List<OrderItem> items, String customerNama) async {
    if (items.isEmpty || _isSubmitting) return false;
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();
    try {
      await _createPesanan(CreatePesananParams(
        items: items.map(_toItemParams).toList(),
        customerNama: customerNama.isEmpty ? null : customerNama,
        orderType: _apiOrderType(effectiveOrderType),
        hold: true,
      ));
      return true;
    } on ApiException catch (e) {
      _submitError = e.message;
      return false;
    } catch (_) {
      _submitError = 'Gagal menyimpan split bill ke Pending.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Pays for the already-created order: `POST /pembayaran`. The order must be
  /// sent to the kitchen first. Returns the payment (with change) or `null`.
  Future<Pembayaran?> bayar({
    required PaymentMethod metode,
    required int jumlahBayar,
  }) async {
    final id = _pesananId;
    if (id == null || _isSubmitting) return null;
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();
    try {
      final payment = await _createPembayaran(
        pesananId: id,
        metode: _apiMetode(metode),
        jumlahBayar: jumlahBayar,
      );
      // Pembayaran sukses → bebaskan meja (status available) bila ada.
      final mid = _mejaId;
      if (mid != null) {
        try {
          await _mejaDatasource.updateStatus(mid, 'available');
        } catch (_) {
          // Non-kritis: pembayaran tetap sukses meski gagal bebaskan meja.
        }
      }
      return payment;
    } on ApiException catch (e) {
      _submitError = e.message;
      return null;
    } catch (_) {
      _submitError = 'Gagal memproses pembayaran.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Membatalkan pesanan (tombol CANCEL). Bila sudah dikirim ke dapur (punya
  /// [pesananId]), batalkan di BE (`POST /pesanan/:id/cancel` → kembalikan stok
  /// & hapus dari dapur) lalu bersihkan cart. Bila belum dikirim, cukup
  /// bersihkan lokal. Selalu mencatat log `VOID_ORDER`.
  /// Mengembalikan `false` bila pembatalan di server gagal (cart tak dibersihkan).
  Future<bool> cancelOrder({String? alasan}) async {
    final id = _pesananId;
    final reason = (alasan != null && alasan.trim().isNotEmpty)
        ? alasan.trim()
        : null;
    _log('VOID_ORDER', reason != null ? 'Batal: $reason' : 'Pesanan dibatalkan');

    if (id != null) {
      if (_isSubmitting) return false;
      _isSubmitting = true;
      _submitError = null;
      notifyListeners();
      try {
        await _cancelPesanan(id);
      } on ApiException catch (e) {
        _submitError = e.message;
        return false;
      } catch (_) {
        _submitError = 'Gagal membatalkan pesanan.';
        return false;
      } finally {
        _isSubmitting = false;
        notifyListeners();
      }
    }
    clear();
    return true;
  }

  CreatePesananItemParams _toItemParams(OrderItem it) {
    final menuId = int.tryParse(it.productId);
    final isCustom = menuId == null;
    // A redeemed free item is charged-then-discounted to net zero so the
    // kitchen still sees it without inflating the total.
    final lineDiskon = it.productId == _redeemedItemId
        ? (it.unitPrice * it.quantity).round()
        : it.discountAmount.round();
    return CreatePesananItemParams(
      menuId: isCustom ? null : menuId,
      namaCustom: isCustom ? it.name : null,
      hargaSatuan: isCustom ? it.unitPrice.round() : null,
      jumlah: it.quantity,
      diskon: lineDiskon,
      catatan: it.note.isEmpty ? null : it.note,
    );
  }

  CreatePesananParams _buildPesananParams({bool hold = false}) {
    final items = _items.map(_toItemParams).toList();

    // Order-level + loyalty discounts are sent as a single nominal amount so the
    // server-computed total matches what the cashier sees.
    final orderDiskon = (orderDiscountAmount + redeemDiscountAmount).round();
    final diskon = orderDiskon > 0
        ? OrderDiscountParams(
            tipe: 'amount',
            nilai: orderDiskon.toDouble(),
            promoNama: _orderPromoName ?? _redeemRewardName,
          )
        : null;

    return CreatePesananParams(
      items: items,
      customerNama: _customerName.isEmpty ? null : _customerName,
      // No In/Away chosen → default to take-away (dine-in is opt-in, and only
      // dine-in requires a meja).
      orderType: _apiOrderType(effectiveOrderType),
      catatan: _orderNote.isEmpty ? null : _orderNote,
      mejaId: _mejaId,
      memberId: _memberId,
      diskon: diskon,
      hold: hold,
    );
  }

  String _apiOrderType(OrderType t) => switch (t) {
        OrderType.dineIn => 'dine_in',
        OrderType.takeAway => 'take_away',
        OrderType.goFood => 'gofood',
        OrderType.grabFood => 'grabfood',
        OrderType.shopeeFood => 'shopeefood',
      };

  String _apiMetode(PaymentMethod m) => switch (m) {
        PaymentMethod.tunai => 'cash',
        PaymentMethod.qris => 'qris',
        PaymentMethod.debitCard => 'debit',
        PaymentMethod.qrisNetzme => 'qris_netzme',
      };

  void clear() {
    if (_items.isEmpty && _orderDiscount == 0 && _orderNote.isEmpty &&
        _customerName.isEmpty &&
        _memberPoints == null && _redeemedPointCost == null &&
        _pesananId == null && _mejaId == null && _kodeTransaksi == null) {
      return;
    }
    // Mulai sesi audit-log baru untuk transaksi berikutnya.
    _kodeTransaksi = null;
    _pesananId = null;
    _serverTotal = null;
    _submitError = null;
    _items.clear();
    _orderDiscount = 0;
    _orderDiscountType = DiscountType.amount;
    _orderPromoName = null;
    _orderNote = '';
    _orderType = null;
    _mejaId = null;
    _mejaNomor = null;
    _customerName = '';
    _memberPoints = null;
    _redeemedPointCost = null;
    _redeemDiscount = 0;
    _redeemDiscountType = DiscountType.amount;
    _redeemRewardName = null;
    _redeemedItemId = null;
    _redeemDisplayValue = null;
    notifyListeners();
  }
}

enum OrderType {
  dineIn,
  takeAway,
  goFood,
  grabFood,
  shopeeFood;

  String get label => switch (this) {
        OrderType.dineIn => 'DINE-IN',
        OrderType.takeAway => 'TAKE-AWAY',
        OrderType.goFood => 'GOFOOD',
        OrderType.grabFood => 'GRABFOOD',
        OrderType.shopeeFood => 'SHOPEEFOOD',
      };
}
