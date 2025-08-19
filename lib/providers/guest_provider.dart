import 'package:flutter/material.dart';
import 'package:planit_mt/models/user/guest_model.dart';
import '../services/firestore_service.dart';

class GuestProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Guest> _guests = [];
  bool _isLoading = false;
  String? _error;

  List<Guest> get guests => _guests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper getters for the dashboard UI
  int get confirmedCount =>
      _guests.where((g) => g.status == GuestStatus.confirmed).length;
  int get pendingCount =>
      _guests.where((g) => g.status == GuestStatus.pending).length;
  int get declinedCount =>
      _guests.where((g) => g.status == GuestStatus.declined).length;
  int get totalCount => _guests.length;

  /// Fetches all guests for a specific event from Firestore.
  Future<void> fetchGuests(String userId, String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _guests = await _firestoreService.getGuests(userId, eventId);
    } catch (e) {
      _error = "Failed to load guests.";
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adds a new guest to the event.
  Future<void> addGuest(String userId, String eventId, String name) async {
    await _firestoreService.addGuest(userId, eventId, name);
    await fetchGuests(userId, eventId); // Refresh the list
  }

  /// Updates the status of a guest.
  Future<void> updateGuestStatus(
      String userId, String eventId, Guest guest, GuestStatus newStatus) async {
    guest.status = newStatus;
    await _firestoreService.updateGuest(userId, eventId, guest);
    await fetchGuests(userId, eventId); // Refresh the list
  }

  /// Deletes a guest from the event.
  Future<void> deleteGuest(
      String userId, String eventId, String guestId) async {
    await _firestoreService.deleteGuest(userId, eventId, guestId);
    await fetchGuests(userId, eventId); // Refresh the list
  }
}
