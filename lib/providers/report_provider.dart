import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

class ReportProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<List<Report>>? _reportsStream;

  Stream<List<Report>>? get reportsStream => _reportsStream;

  // Constructor is now empty to implement lazy loading.
  ReportProvider();

  void fetchReports() {
    // Avoid creating a new stream if one already exists.
    if (_reportsStream == null) {
      _reportsStream = _firestoreService.getReports();
      notifyListeners();
    }
  }

  Future<void> createReport(Report report) async {
    await _firestoreService.createReport(report);
    // Stream will update automatically
  }

  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    await _firestoreService.updateReportStatus(reportId, status);
    // Stream will update automatically
  }
}
