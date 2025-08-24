import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/models/event_model.dart';
import 'package:planit_mt/models/vendor/app_vendor.dart';
import 'package:planit_mt/services/booking_service.dart';
import 'package:planit_mt/services/firestore_service.dart';
import 'package:planit_mt/utils/id_generator.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final FirestoreService _firestoreService = FirestoreService();
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

  Future<bool> createBookingsForPackage({
    required String userId,
    required EventModel event,
    required List<AppVendor> vendors,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      for (final vendor in vendors) {
        final newBooking = BookingModel(
          bookingId: generateUniqueId(),
          userId: userId,
          vendorId: vendor.vendorId,
          vendorName: vendor.name,
          vendorCategory: vendor.category,
          vendorPrice: vendor.price,
          eventId: event.id,
          eventTitle: event.title,
          bookingDate: event.date,
          status: BookingStatus.pending,
          createdAt: Timestamp.now(),
        );
        await _bookingService.createBookingRequest(newBooking);
      }
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to create package booking requests: $e";
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus newStatus) async {
    try {
      final originalBooking =
          _vendorBookings.firstWhere((b) => b.bookingId == bookingId);
      final wasConfirmed = originalBooking.status == BookingStatus.confirmed;

      if (newStatus == BookingStatus.confirmed) {
        await _bookingService.confirmBookingInTransaction(originalBooking);
      } else if (newStatus == BookingStatus.cancelled && wasConfirmed) {
        await _bookingService.releaseBookingInTransaction(originalBooking);
      } else {
        await _bookingService.updateBookingStatus(bookingId, newStatus);
      }

      // This logic is crucial: update the budget ONLY when a booking is confirmed or a confirmed booking is cancelled.
      if (newStatus == BookingStatus.confirmed && !wasConfirmed) {
        await _firestoreService.updateEventSpentBudget(
          userId: originalBooking.userId,
          eventId: originalBooking.eventId,
          amountToAdd: originalBooking.vendorPrice,
        );
      } else if (wasConfirmed &&
          (newStatus == BookingStatus.declined ||
              newStatus == BookingStatus.cancelled)) {
        await _firestoreService.updateEventSpentBudget(
          userId: originalBooking.userId,
          eventId: originalBooking.eventId,
          amountToAdd: -originalBooking.vendorPrice,
        );
      }
    } catch (e) {
      _error = "Failed to update booking status: $e";
      debugPrint(_error);
      notifyListeners();
      // Rethrow the exception so the UI can catch it and show an error.
      throw Exception(_error);
    }
  }

  Future<void> userCancelBooking(String bookingId) async {
    try {
      final originalBooking =
          _userBookings.firstWhere((b) => b.bookingId == bookingId);
      final wasConfirmed = originalBooking.status == BookingStatus.confirmed;

      if (wasConfirmed) {
        await _bookingService.releaseBookingInTransaction(originalBooking);
        await _firestoreService.updateEventSpentBudget(
          userId: originalBooking.userId,
          eventId: originalBooking.eventId,
          amountToAdd: -originalBooking.vendorPrice, // Subtract the price
        );
      } else {
        await _bookingService.updateBookingStatus(
            bookingId, BookingStatus.cancelled);
      }
    } catch (e) {
      _error = "Failed to cancel booking: $e";
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
