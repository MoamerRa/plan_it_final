import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadPostImage({
    required File imageFile,
    required String uid,
  }) async {
    try {
      final fileName =
          '${uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('post_images').child(fileName);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
      return null;
    }
  }

  Future<String?> uploadVendorGalleryImage({
    required File imageFile,
    required String uid,
  }) async {
    try {
      final fileName =
          '${uid}_gallery_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('vendor_gallery_images').child(fileName);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading gallery image: $e");
      }
      return null;
    }
  }

  Future<String?> uploadVendorProfileImage({
    required File imageFile,
    required String uid,
  }) async {
    try {
      final fileName = 'profile_$uid${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('vendor_profile_images').child(fileName);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading vendor profile image: $e");
      }
      return null;
    }
  }

  Future<String?> uploadUserProfileImage({
    required File imageFile,
    required String uid,
  }) async {
    try {
      // FIX: Removed unnecessary braces in string interpolation
      final fileName = '$uid${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('user_profile_images').child(fileName);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading user profile image: $e");
      }
      return null;
    }
  }
}
