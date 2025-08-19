import 'package:flutter/foundation.dart';
import 'package:planit_mt/models/admin/app_admin.dart';
import 'package:planit_mt/models/vendor/app_vendor.dart';
import 'package:planit_mt/screens/admin/platform_stats_model.dart';
import 'package:planit_mt/services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  // The service is now a final variable, not initialized directly.
  final AdminService _adminService;

  AdminModel? _admin;
  List<AppVendor> _pendingVendors = [];
  List<AppVendor> _allVendors = [];
  PlatformStats? _stats;
  bool _isLoading = false;
  String? _error;

  AdminModel? get admin => _admin;
  List<AppVendor> get pendingVendors => _pendingVendors;
  List<AppVendor> get allVendors => _allVendors;
  PlatformStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // The constructor now accepts an optional AdminService.
  // This makes the code testable and follows best practices.
  AdminProvider({AdminService? adminService})
      : _adminService = adminService ?? AdminService() {
    // fetchAllData() is removed from here to implement lazy loading.
    // It should be called from the UI (e.g., in initState of AdminHomeScreen).
  }

  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingVendors = await _adminService.getPendingVendors();
    } catch (e) {
      _error = "Failed to load pending vendors.";
      if (kDebugMode) print(e);
    }

    try {
      _allVendors = await _adminService.getAllVendors();
    } catch (e) {
      _error = "Failed to load all vendors.";
      if (kDebugMode) print(e);
    }

    try {
      _stats = await _adminService.getPlatformStatistics();
    } catch (e) {
      _error = "Failed to load platform statistics.";
      if (kDebugMode) print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setAdmin(AdminModel admin) {
    _admin = admin;
    notifyListeners();
  }

  Future<void> fetchPendingVendors() async {
    _isLoading = true;
    notifyListeners();
    _pendingVendors = await _adminService.getPendingVendors();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllVendors() async {
    _isLoading = true;
    notifyListeners();
    _allVendors = await _adminService.getAllVendors();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPlatformStats() async {
    _isLoading = true;
    notifyListeners();
    _stats = await _adminService.getPlatformStatistics();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveVendor(String vendorId) async {
    await _adminService.updateVendorApprovalStatus(vendorId, true);
    await fetchAllData(); // Refresh all data
  }

  Future<void> declineVendor(String vendorId) async {
    await _adminService.deleteVendor(vendorId);
    await fetchAllData(); // Refresh all data
  }

  Future<void> deleteVendor(String vendorId) async {
    await _adminService.deleteVendor(vendorId);
    await fetchAllData(); // Refresh all data
  }
}
