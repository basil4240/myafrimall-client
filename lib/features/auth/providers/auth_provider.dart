import 'package:flutter/material.dart';
import '../../../core/network/network.dart';
import '../data/models/auth_models.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  bool _unverifiedEmail = false;
  AuthUser? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get unverifiedEmail => _unverifiedEmail;
  AuthUser? get currentUser => _currentUser;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    _isAuthenticated = await AppStorage.instance.hasTokens();
    if (_isAuthenticated) {
      try {
        _currentUser = await _repository.fetchProfile();
      } catch (_) {}
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _begin();
    try {
      final res = await _repository.login(email: email, password: password);
      _currentUser = res.user;
      _isAuthenticated = true;
    } on UnverifiedEmailException {
      _unverifiedEmail = true;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _end();
    }
  }

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _begin();
    try {
      await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
    } on UnverifiedEmailException {
      _unverifiedEmail = true;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _end();
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _begin();
    try {
      final res = await _repository.verifyOtp(email: email, otp: otp);
      _currentUser = res.user;
      _isAuthenticated = true;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _end();
    }
  }

  Future<void> resendOtp({required String email}) async {
    _begin();
    try {
      await _repository.resendOtp(email: email);
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _end();
    }
  }

  Future<void> forgotPassword({required String email}) async {
    _begin();
    try {
      await _repository.forgotPassword(email: email);
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _end();
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    _begin();
    try {
      await _repository.resetPassword(email: email, otp: otp, password: password);
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _end();
    }
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    _error = null;
    _unverifiedEmail = false;
    AppStorage.instance.clearTokens();
    notifyListeners();
  }

  void forceLogout() {
    logout();
  }

  void clearError() {
    _error = null;
    _unverifiedEmail = false;
    notifyListeners();
  }

  void _begin() {
    _isSubmitting = true;
    _error = null;
    _unverifiedEmail = false;
    notifyListeners();
  }

  void _end() {
    _isSubmitting = false;
    notifyListeners();
  }
}
