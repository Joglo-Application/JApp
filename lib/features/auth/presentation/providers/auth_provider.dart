import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/auth_repository.dart';
import '../../data/models/auth_user_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repo = repository ?? AuthRepository();

  final AuthRepository _repo;

  bool _isLoading = false;
  String? _error;
  AuthUser? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;

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
