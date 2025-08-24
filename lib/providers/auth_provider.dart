import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planit_mt/services/sqlite_helper.dart';
import '../models/admin/app_admin.dart';
import '../models/user/user_model.dart';
import '../models/vendor/app_vendor.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/id_generator.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;

  bool get isLoggedIn => _firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final existingUserError = await _firestoreService.checkIfUserExists(
        email: email,
        phone: phone,
      );
      if (existingUserError != null) {
        return existingUserError;
      }

      String? authError =
          await _authService.signUp(email: email, password: password);
      if (authError != null) {
        return authError;
      }

      String? uid = _authService.currentUser?.uid;
      if (uid == null) {
        return "Could not create user. UID is null.";
      }

      if (role == 'vendor') {
        final newVendor = AppVendor(
          vendorId: uid,
          name: name,
          email: email,
          phone: phone,
          category: 'Uncategorized',
          description: '',
          imageUrl: '',
          galleryUrls: [],
          rating: 0.0,
          price: 0.0,
          isApproved: false,
        );
        await _firestoreService.createVendor(newVendor);
      } else if (role == 'admin') {
        final newAdmin = AdminModel(
          id: uid,
          name: name,
          email: email,
          role: 'admin',
        );
        await _firestoreService.createAdmin(newAdmin);
      } else {
        // 'user'
        final newUser = UserModel(
          id: uid,
          name: name,
          email: email,
          phone: phone,
          role: 'user',
          customId: generateCustomId(role),
        );
        await _firestoreService.createUser(newUser);
      }

      await _authService.signOut();

      return null; // Success
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
    }
  }

  Future<String?> signIn(
      {required String email, required String password}) async {
    return await _authService.signIn(email: email, password: password);
  }

  // ================== FIX FOR ISSUE #2 (Part 2) ==================
  Future<void> signOut() async {
    await _authService.signOut();
    // Clear local tasks to prevent data leakage between users on the same device.
    await SQLiteHelper.clearAllTasks();
  }
  // ================================================================

  Future<String?> resetPassword({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      }
      return 'An error occurred. Please try again later.';
    } catch (e) {
      debugPrint("Password Reset Error: $e");
      return 'An unexpected error occurred.';
    }
  }

  void setUserModel(UserModel user) {
    _userModel = user;
    notifyListeners();
  }
}
