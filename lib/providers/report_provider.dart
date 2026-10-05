import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../models/health_report.dart';
import '../services/storage_service.dart';

class ReportProvider with ChangeNotifier {
  final StorageService _storageService;

  List<Prescription> _prescriptions = [];
  List<HealthReport> _reports = [];

  bool _isLoading = true;

  ReportProvider(this._storageService) {
    _loadData();
  }

  bool get isLoading => _isLoading;
  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);
  List<HealthReport> get reports => List.unmodifiable(_reports);

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    _prescriptions = _storageService.loadPrescriptions();
    _reports = _storageService.loadReports();

    _isLoading = false;
    notifyListeners();
  }

  // Prescriptions CRUD
  Future<void> addPrescription(Prescription item) async {
    _prescriptions.insert(0, item);
    await _storageService.savePrescriptions(_prescriptions);
    notifyListeners();
  }

  Future<void> deletePrescription(String id) async {
    _prescriptions.removeWhere((p) => p.id == id);
    await _storageService.savePrescriptions(_prescriptions);
    notifyListeners();
  }

  // Reports CRUD
  Future<void> addReport(HealthReport report) async {
    _reports.insert(0, report);
    await _storageService.saveReports(_reports);
    notifyListeners();
  }

  Future<void> deleteReport(String id) async {
    _reports.removeWhere((r) => r.id == id);
    await _storageService.saveReports(_reports);
    notifyListeners();
  }

  List<HealthReport> getReportsByCategory(String category) {
    if (category == 'All') return _reports;
    return _reports.where((r) => r.category == category).toList();
  }
}
