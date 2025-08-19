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
}
