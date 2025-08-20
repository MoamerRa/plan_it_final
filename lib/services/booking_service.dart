import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planit_mt/models/booking_model.dart';

class BookingService {
  final CollectionReference _bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');

  // Create a new booking request
  Future<void> createBookingRequest(BookingModel booking) async {
    // Use bookingId as the document ID for easy access
    await _bookingsCollection.doc(booking.bookingId).set(booking.toMap());
  }

  // Get a real-time stream of bookings for a specific vendor
  Stream<List<BookingModel>> getVendorBookingsStream(String vendorId) {
    return _bookingsCollection
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get a real-time stream of bookings for a specific user
  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update the status of a booking
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await _bookingsCollection
        .doc(bookingId)
        .update({'status': status.toString().split('.').last});
  }

  // NEW METHOD
  /// Checks if a specific vendor is available on a given date.
  /// Returns true if available, false if they have a confirmed booking.
  Future<bool> isVendorAvailable(String vendorId, DateTime date) async {
    final startOfDay =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final endOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59));

    final snapshot = await _bookingsCollection
        .where('vendorId', isEqualTo: vendorId)
        .where('status',
            isEqualTo: BookingStatus.confirmed.toString().split('.').last)
        .where('bookingDate', isGreaterThanOrEqualTo: startOfDay)
        .where('bookingDate', isLessThanOrEqualTo: endOfDay)
        .limit(1)
        .get();

    return snapshot.docs.isEmpty; // If empty, vendor is available.
  }

  // NEW METHOD
  /// Fetches all CONFIRMED bookings for a specific date to check general availability.
  Future<List<BookingModel>> getConfirmedBookingsForDate(DateTime date) async {
    final startOfDay =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final endOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59));

    final snapshot = await _bookingsCollection
        .where('status',
            isEqualTo: BookingStatus.confirmed.toString().split('.').last)
        .where('bookingDate', isGreaterThanOrEqualTo: startOfDay)
        .where('bookingDate', isLessThanOrEqualTo: endOfDay)
        .get();

    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
