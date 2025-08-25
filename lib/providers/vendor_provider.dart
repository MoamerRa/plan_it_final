import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vendor/app_vendor.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class VendorProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppVendor? _vendor;
  List<AppVendor> _approvedVendors = [];
  bool _isLoading = false;
  String? _error;

  AppVendor? get vendor => _vendor;
  List<AppVendor> get approvedVendors => _approvedVendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  VendorProvider();

  void setVendor(AppVendor vendor) {
    _vendor = vendor;
    notifyListeners();
  }

  // ================== FIX FOR ISSUE #1 ==================
  // The guard clause `if (_approvedVendors.isNotEmpty) return;` has been removed.
  // This ensures that the vendor list is always fetched fresh from Firestore
  // when the user navigates to the Explore page, showing newly approved vendors.
  Future<void> fetchApprovedVendors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _approvedVendors = await _firestoreService.getApprovedVendors();
    } catch (e) {
      _error = "Failed to load vendors. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // ======================================================

  Future<String?> updateProfile({
    required String description,
    required double price,
    required String category,
    required List<File> newGalleryImages,
  }) async {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null || _vendor == null) {
      _isLoading = false;
      notifyListeners();
      return "No vendor is logged in.";
    }

    try {
      List<String> newImageUrls = [];
      for (var imageFile in newGalleryImages) {
        final imageUrl = await _storageService.uploadVendorGalleryImage(
          imageFile: imageFile,
          uid: user.uid,
        );
        if (imageUrl != null) {
          newImageUrls.add(imageUrl);
        }
      }

      final updatedData = {
        'description': description,
        'price': price,
        'category': category,
        'galleryUrls': FieldValue.arrayUnion(newImageUrls),
      };

      await _firestoreService.updateVendorProfile(user.uid, updatedData);

      _vendor = _vendor!.copyWith(
        description: description,
        price: price,
        category: category,
        galleryUrls: [..._vendor!.galleryUrls, ...newImageUrls],
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
