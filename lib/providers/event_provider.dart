import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<EventModel?>? _eventSubscription;

  EventModel? _activeEvent;
  bool _isLoading = false;
  String? _error;

  EventModel? get activeEvent => _activeEvent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // UPDATED: Now listens for real-time changes
  void listenToUserEvent(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _eventSubscription?.cancel(); // Cancel any previous listener
    _eventSubscription =
        _firestoreService.getActiveUserEventStream(userId).listen((event) {
      _activeEvent = event;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = "Failed to listen to event updates: $e";
      _isLoading = false;
      notifyListeners();
    });
  }

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
      _activeEvent = newEvent;
      return null;
    } catch (e) {
      _error = "Failed to create event: ${e.toString()}";
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateActiveEventDate(DateTime newDate) async {
    if (_activeEvent == null) {
      _error = "No active event to update.";
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateEventDate(
        _activeEvent!.userId,
        _activeEvent!.id,
        newDate,
      );
      _activeEvent = _activeEvent!.copyWith(date: newDate);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to update event date: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearAllEvents() {
    _activeEvent = null;
    _eventSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
