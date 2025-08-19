import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  EventModel? _activeEvent;
  bool _isLoading = false;
  String? _error;

  EventModel? get activeEvent => _activeEvent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads the active event for the given user from Firestore.
  Future<void> loadUserEvent(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _activeEvent = await _firestoreService.getActiveUserEvent(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// Creates a new event and saves it to Firestore.
  Future<String?> createNewEvent({
    required String title,
    required DateTime date,
    required double totalBudget,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create a new document reference to get a unique ID
      final newEventRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc();

      final newEvent = EventModel(
        id: newEventRef.id,
        userId: userId,
        title: title,
        date: date,
        totalBudget: totalBudget,
      );

      await _firestoreService.saveUserEvent(newEvent);
      _activeEvent = newEvent; // Set the new event as active
      return null; // Success
    } catch (e) {
      _error = "Failed to create event: ${e.toString()}";
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAllEvents() {
    _activeEvent = null;
    notifyListeners();
  }
}
