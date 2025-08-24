import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planit_mt/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');

  // Create a new booking request
  Future<void> createBookingRequest(BookingModel booking) async {
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

  // Simple update for status changes like 'decline'
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await _bookingsCollection
        .doc(bookingId)
        .update({'status': status.toString().split('.').last});
  }

  // ================== NEW ROBUST FIX FOR ISSUE #3 ==================
  // This method uses a transaction to create an "availability lock" document.
  // This is the correct way to prevent race conditions in Firestore.
  Future<void> confirmBookingInTransaction(
      BookingModel bookingToConfirm) async {
    final date = bookingToConfirm.bookingDate;
    // Create a predictable, unique ID for the availability slot.
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final availabilityId = "${bookingToConfirm.vendorId}_$dateString";
    final availabilityRef =
        _db.collection('vendorAvailability').doc(availabilityId);

    final bookingRef = _bookingsCollection.doc(bookingToConfirm.bookingId);

    return _db.runTransaction((transaction) async {
      // Step 1: Try to read the availability lock document.
      final availabilityDoc = await transaction.get(availabilityRef);

      // Step 2: If the document already exists, it means the slot is taken. Abort.
      if (availabilityDoc.exists) {
        throw Exception('This vendor is already booked for this date.');
      }

      // Step 3: The slot is free.
      // a) Create the lock document to block other transactions.
      transaction.set(availabilityRef, {
        'bookingId': bookingToConfirm.bookingId,
        'userId': bookingToConfirm.userId,
      });
      // b) Update the original booking document's status to 'confirmed'.
      transaction.update(bookingRef,
          {'status': BookingStatus.confirmed.toString().split('.').last});
    });
  }

  // NEW: A transactional method to release the availability lock when a booking is cancelled.
  Future<void> releaseBookingInTransaction(BookingModel bookingToCancel) async {
    final date = bookingToCancel.bookingDate;
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final availabilityId = "${bookingToCancel.vendorId}_$dateString";
    final availabilityRef =
        _db.collection('vendorAvailability').doc(availabilityId);

    final bookingRef = _bookingsCollection.doc(bookingToCancel.bookingId);

    return _db.runTransaction((transaction) async {
      // Atomically delete the lock and update the booking status.
      transaction.delete(availabilityRef);
      transaction.update(bookingRef,
          {'status': BookingStatus.cancelled.toString().split('.').last});
    });
  }
  // ==================================================================

  // Checks if a specific vendor is available on a given date.
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

  // Fetches all CONFIRMED bookings for a specific date to check general availability.
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
