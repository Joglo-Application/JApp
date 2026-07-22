import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/auth_repository.dart';
import '../../data/models/auth_user_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repo = repository ?? AuthRepository() {
    // Pulihkan sesi sekali saat app dibuat — berlaku untuk semua titik masuk,
    // termasuk refresh / deep-link di web yang tidak melewati Splash.
    _bootstrap = tryAutoLogin();
  }

  final AuthRepository _repo;

  /// Future restore-sesi awal; dipakai Splash untuk menunggu tanpa memicu
  /// `/auth/me` kedua kali.
  Future<bool>? _bootstrap;
  Future<bool> ensureBootstrapped() => _bootstrap ??= tryAutoLogin();

  bool _isLoading = false;
  String? _error;
  AuthUser? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;

  /// Role yang memiliki tab Inventori dengan hak CRUD penuh atas produk:
  /// dapur, gudang, dan kasir. Role lain (supervisor, owner, admin) melihat
  /// daftar sebagai read-only; server pun menolak tulisan di luar ketiga role
  /// ini (403).
  static const _inventoriManagers = {'dapur', 'gudang', 'kasir'};
  bool get canManageInventori => _inventoriManagers.contains(_user?.role);

  /// Halaman awal sesuai role user yang login.
  String get landingRoute {
    switch (_user?.role) {
      case 'owner':
        return AppRoutes.ownerDashboard;
      case 'supervisor':
        return AppRoutes.spvTransaksi;
      case 'kasir':
        return AppRoutes.pos;
      case 'dapur':
        return AppRoutes.kitchenDapur;
      case 'gudang':
        return AppRoutes.supplierGudang;
      default:
        return AppRoutes.pos;
    }
  }

  /// Authenticates against the backend. Returns `true` on success.
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repo.login(username, password);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan tak terduga. Coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restores a session from the stored token (calls `/auth/me`).
  /// Returns `true` if the token is still valid.
  Future<bool> tryAutoLogin() async {
    try {
      _user = await _repo.me();
      notifyListeners();
      return true;
    } catch (_) {
      _user = null;
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
