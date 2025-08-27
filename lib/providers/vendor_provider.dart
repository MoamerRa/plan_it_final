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

  Future<String?> updateProfile({
    required String description,
    required double price,
    required String category,
    required List<File> newGalleryImages,
    File? newProfileImage,
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
      String newProfileImageUrl =
          _vendor!.imageUrl; // Start with the existing URL
      List<String> newGalleryImageUrls = [];

      // --- 1. Handle Profile Image Upload with Error Checking ---
      if (newProfileImage != null) {
        final uploadedUrl = await _storageService.uploadVendorProfileImage(
          imageFile: newProfileImage,
          uid: user.uid,
        );
        // If upload fails, stop the process and return an error.
        if (uploadedUrl == null) {
          return "Failed to upload profile image. Please check permissions or try again.";
        }
        newProfileImageUrl = uploadedUrl;
      }

      // --- 2. Handle Gallery Images Upload ---
      for (var imageFile in newGalleryImages) {
        final uploadedUrl = await _storageService.uploadVendorGalleryImage(
          imageFile: imageFile,
          uid: user.uid,
        );
        if (uploadedUrl != null) {
          newGalleryImageUrls.add(uploadedUrl);
        }
      }

      // --- 3. Prepare data for Firestore ---
      final updatedData = {
        'description': description,
        'price': price,
        'category': category,
        'galleryUrls': FieldValue.arrayUnion(newGalleryImageUrls),
        'imageUrl': newProfileImageUrl, // Use the potentially new URL
      };

      await _firestoreService.updateVendorProfile(user.uid, updatedData);

      // --- 4. Update local state correctly ---
      _vendor = _vendor!.copyWith(
        description: description,
        price: price,
        category: category,
        imageUrl: newProfileImageUrl, // Update the image URL in the local state
        galleryUrls: [
          ..._vendor!.galleryUrls,
          ...newGalleryImageUrls
        ], // Append new gallery URLs
      );

      return null; // Success
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
