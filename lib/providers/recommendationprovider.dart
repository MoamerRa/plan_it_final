import 'package:flutter/material.dart';
import 'package:planit_mt/models/user/recommendationmodel.dart';
import '../models/vendor/app_vendor.dart';

class RecommendationProvider with ChangeNotifier {
  List<RecommendedPackage> _recommendations = [];
  bool _isLoading = false;

  List<RecommendedPackage> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  /// Generates event package recommendations based on available vendors and budget.
  Future<void> generateRecommendations({
    required List<AppVendor> allApprovedVendors,
    required DateTime date,
    required double budget,
    String? preferredCategory,
  }) async {
    _isLoading = true;
    _recommendations = [];
    notifyListeners();

    // Simulate a network delay for a better user experience
    await Future.delayed(const Duration(seconds: 2));

    // 1. Separate vendors by category for easier combination
    final halls =
        allApprovedVendors.where((v) => v.category == 'Hall').toList();
    final djs = allApprovedVendors.where((v) => v.category == 'DJ').toList();
    final caterers =
        allApprovedVendors.where((v) => v.category == 'Catering').toList();

    // 2. Simple algorithm: try to combine one of each essential category
    if (halls.isNotEmpty && djs.isNotEmpty && caterers.isNotEmpty) {
      for (final hall in halls) {
        for (final dj in djs) {
          for (final caterer in caterers) {
            final double packagePrice = hall.price + dj.price + caterer.price;

            // 3. Check if the combined price is within the user's budget
            if (packagePrice <= budget) {
              final newPackage = RecommendedPackage(
                name: 'Package with ${hall.name}',
                date: date,
                totalPrice: packagePrice,
                vendors: [
                  VendorInfo(name: hall.name, category: hall.category),
                  VendorInfo(name: dj.name, category: dj.category),
                  VendorInfo(name: caterer.name, category: caterer.category),
                ],
              );
              _recommendations.add(newPackage);

              // Stop after finding a few packages to not overwhelm the user
              if (_recommendations.length >= 3) break;
            }
          }
          if (_recommendations.length >= 3) break;
        }
        if (_recommendations.length >= 3) break;
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
