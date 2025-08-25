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
  }) {
    /* ... unchanged ... */ _isLoading = true;
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
        _bookingService.createBookingRequest(newBooking);
      }
      _isLoading = false;
      _error = null;
      notifyListeners();
      return Future.value(true);
    } catch (e) {
      _error = "Failed to create package booking requests: $e";
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return Future.value(false);
    }
  }

  void fetchVendorBookings(String vendorId) {
    /* ... unchanged ... */ _isLoading = true;
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
    /* ... unchanged ... */ _isLoading = true;
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

      // ================== FIX FOR ISSUE #3 ==================
      // If the vendor declined the request, create a notification for the user.
      if (newStatus == BookingStatus.declined) {
        await _firestoreService.addUserNotification(
          userId: originalBooking.userId,
          message:
              "Unfortunately, your booking request with ${originalBooking.vendorName} for ${originalBooking.eventTitle} has been declined.",
        );
      }
      // ======================================================
    } catch (e) {
      _error = "Failed to update booking status: $e";
      debugPrint(_error);
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> userCancelBooking(String bookingId) {
    /* ... unchanged ... */ try {
      final originalBooking =
          _userBookings.firstWhere((b) => b.bookingId == bookingId);
      final wasConfirmed = originalBooking.status == BookingStatus.confirmed;

      if (wasConfirmed) {
        _bookingService.releaseBookingInTransaction(originalBooking);
        _firestoreService.updateEventSpentBudget(
          userId: originalBooking.userId,
          eventId: originalBooking.eventId,
          amountToAdd: -originalBooking.vendorPrice, // Subtract the price
        );
      } else {
        _bookingService.updateBookingStatus(bookingId, BookingStatus.cancelled);
      }
      return Future.value();
    } catch (e) {
      _error = "Failed to cancel booking: $e";
      debugPrint(_error);
      notifyListeners();
      return Future.error(e);
    }
  }

  @override
  void dispose() {
    _vendorBookingsSubscription?.cancel();
    _userBookingsSubscription?.cancel();
    super.dispose();
  }
}
