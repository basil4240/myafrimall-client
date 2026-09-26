import 'package:flutter/material.dart';
import '../../../core/network/app_exception.dart';
import '../../shipments/data/models/shipment_model.dart';
import '../../shipments/data/repositories/shipments_repository.dart';
import '../data/models/dashboard_models.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepo;
  final ShipmentsRepository _shipmentsRepo;

  DashboardProvider({
    DashboardRepository? dashboardRepo,
    ShipmentsRepository? shipmentsRepo,
  })  : _dashboardRepo = dashboardRepo ?? DashboardRepository(),
        _shipmentsRepo = shipmentsRepo ?? ShipmentsRepository();

  bool _isLoading = false;
  String? _error;
  DashboardOverview? _overview;
  List<Shipment> _recentShipments = [];
  String _selectedPeriod = 'month';

  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardOverview? get overview => _overview;
  List<Shipment> get recentShipments => _recentShipments;
  String get selectedPeriod => _selectedPeriod;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await Future.wait([_fetchOverview(), _fetchRecentShipments()]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changePeriod(String period) async {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
    await _fetchOverview();
    notifyListeners();
  }

  Future<void> _fetchOverview() async {
    try {
      _overview = await _dashboardRepo.getOverview(period: _selectedPeriod);
    } on AppException catch (e) {
      _error = e.message;
    }
  }

  Future<void> _fetchRecentShipments() async {
    try {
      final result = await _shipmentsRepo.getShipments(page: 1, limit: 5);
      _recentShipments = result.items;
    } on AppException catch (e) {
      _error = e.message;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
