import 'package:flutter/material.dart';
import '../../../core/network/app_exception.dart';
import '../data/models/address_model.dart';
import '../data/repositories/addresses_repository.dart';

class AddressesProvider extends ChangeNotifier {
  final AddressesRepository _repository;

  AddressesProvider({AddressesRepository? repository})
      : _repository = repository ?? AddressesRepository();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<Address> _addresses = [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<Address> get addresses => _addresses;

  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _repository.getAddresses();
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final address = await _repository.createAddress(data);
      if (address.isDefault) {
        _addresses = _addresses
            .map((a) => a.copyWith(isDefault: false))
            .toList();
      }
      _addresses = [address, ..._addresses];
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateAddress(id, data);
      if (updated.isDefault) {
        _addresses = _addresses
            .map((a) => a.copyWith(isDefault: false))
            .toList();
      }
      _addresses = _addresses.map((a) => a.id == id ? updated : a).toList();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteAddress(id);
      _addresses = _addresses.where((a) => a.id != id).toList();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> setDefault(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.setDefault(id);
      _addresses = _addresses
          .map((a) => a.copyWith(isDefault: a.id == id))
          .toList();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
