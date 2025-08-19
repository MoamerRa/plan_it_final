import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/services/booking_service.dart';
import 'package:planit_mt/utils/id_generator.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  StreamSubscription? _vendorBookingsSubscription;
  StreamSubscription? _userBookingsSubscription;

  List<BookingModel> _vendorBookings = [];
  List<BookingModel> get vendorBookings => _vendorBookings;

  List<BookingModel> _userBookings = [];
  List<BookingModel> get userBookings => _userBookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // For User: Create a booking request
  Future<bool> createBookingRequest({
    required String userId,
    required String vendorId,
    required String vendorName,
    required String eventId,
    required String eventTitle,
    required DateTime bookingDate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newBooking = BookingModel(
        bookingId: generateUniqueId(), // Now this function is recognized
        userId: userId,
        vendorId: vendorId,
        vendorName: vendorName,
        eventId: eventId,
        eventTitle: eventTitle,
        bookingDate: bookingDate,
        status: BookingStatus.pending,
        createdAt: Timestamp.now(),
      );
      await _bookingService.createBookingRequest(newBooking);
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to create booking request: $e";
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // For Vendor: Listen to incoming booking requests
  void fetchVendorBookings(String vendorId) {
    _isLoading = true;
    notifyListeners();
    _vendorBookingsSubscription?.cancel();
    _vendorBookingsSubscription =
        _bookingService.getVendorBookingsStream(vendorId).listen((bookings) {
      _vendorBookings = bookings;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = "Failed to fetch vendor bookings: $e";
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
    });
  }

  // For User: Listen to their own bookings
  void fetchUserBookings(String userId) {
    _isLoading = true;
    notifyListeners();
    _userBookingsSubscription?.cancel();
    _userBookingsSubscription =
        _bookingService.getUserBookingsStream(userId).listen((bookings) {
      _userBookings = bookings;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = "Failed to fetch user bookings: $e";
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
    });
  }

  // For Vendor: Update booking status
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus newStatus) async {
    try {
      await _bookingService.updateBookingStatus(bookingId, newStatus);
    } catch (e) {
      _error = "Failed to update booking status: $e";
      debugPrint(_error);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _vendorBookingsSubscription?.cancel();
    _userBookingsSubscription?.cancel();
    super.dispose();
  }
}
