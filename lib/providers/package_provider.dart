import 'package:flutter/material.dart';
import 'package:planit_mt/models/vendor/app_vendor.dart';

/// A provider to manage the user's selected vendor package (like a shopping cart).
class PackageProvider with ChangeNotifier {
  final List<AppVendor> _selectedVendors = [];

  List<AppVendor> get selectedVendors => _selectedVendors;

  /// The total price of all vendors currently in the package.
  double get totalPrice =>
      _selectedVendors.fold(0.0, (sum, vendor) => sum + vendor.price);

  /// Checks if a specific vendor is already in the package.
  bool isVendorInPackage(AppVendor vendor) {
    return _selectedVendors.any((v) => v.vendorId == vendor.vendorId);
  }

  /// Adds a vendor to the package if they are not already in it.
  void addVendor(AppVendor vendor) {
    if (!isVendorInPackage(vendor)) {
      _selectedVendors.add(vendor);
      notifyListeners();
    }
  }

  /// Removes a vendor from the package.
  void removeVendor(AppVendor vendor) {
    _selectedVendors.removeWhere((v) => v.vendorId == vendor.vendorId);
    notifyListeners();
  }

  /// Clears all vendors from the package.
  void clearPackage() {
    _selectedVendors.clear();
    notifyListeners();
  }
}
