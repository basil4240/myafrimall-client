import 'package:flutter/material.dart';
import '../../../core/models/pagination_meta.dart';
import '../../../core/network/app_exception.dart';
import '../data/models/shipment_model.dart';
import '../data/repositories/shipments_repository.dart';

class ShipmentsProvider extends ChangeNotifier {
  final ShipmentsRepository _repository;

  ShipmentsProvider({ShipmentsRepository? repository})
      : _repository = repository ?? ShipmentsRepository();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<Shipment> _shipments = [];
  PaginationMeta? _meta;
  int _currentPage = 1;
  static const int _limit = 10;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<Shipment> get shipments => _shipments;
  bool get hasMore => _meta?.hasNext ?? false;

  Future<void> loadShipments({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _shipments = [];
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getShipments(
        page: _currentPage,
        limit: _limit,
      );
      _shipments = refresh
          ? result.items
          : [..._shipments, ...result.items];
      _meta = result.meta;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || _isLoading) return;
    _currentPage++;
    await loadShipments();
  }

  Future<bool> createShipment({
    required String senderName,
    required String pickupAddress,
    required String receiverName,
    required String deliveryAddress,
    required double weight,
    required String description,
    required String serviceType,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final shipment = await _repository.createShipment(
        senderName: senderName,
        pickupAddress: pickupAddress,
        receiverName: receiverName,
        deliveryAddress: deliveryAddress,
        weight: weight,
        description: description,
        serviceType: serviceType,
      );
      _shipments = [shipment, ..._shipments];
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateShipment({
    required String id,
    required String senderName,
    required String pickupAddress,
    required String receiverName,
    required String deliveryAddress,
    required double weight,
    required String description,
    required String serviceType,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateShipment(
        id: id,
        senderName: senderName,
        pickupAddress: pickupAddress,
        receiverName: receiverName,
        deliveryAddress: deliveryAddress,
        weight: weight,
        description: description,
        serviceType: serviceType,
      );
      _shipments = _shipments.map((s) => s.id == id ? updated : s).toList();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteShipment(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteShipment(id);
      _shipments = _shipments.where((s) => s.id != id).toList();
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
