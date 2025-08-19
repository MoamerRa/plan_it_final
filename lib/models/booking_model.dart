import 'package:cloud_firestore/cloud_firestore.dart';

// Using an enum for status is great practice!
enum BookingStatus {
  pending,
  confirmed,
  declined,
  cancelled,
}

class BookingModel {
  final String bookingId;
  final String eventId;
  final String userId;
  final String vendorId;
  final String vendorName; // Denormalized data for easier display
  final String eventTitle; // Denormalized data
  final DateTime bookingDate;
  final BookingStatus status;
  final Timestamp createdAt;

  BookingModel({
    required this.bookingId,
    required this.eventId,
    required this.userId,
    required this.vendorId,
    required this.vendorName,
    required this.eventTitle,
    required this.bookingDate,
    this.status = BookingStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'eventId': eventId,
      'userId': userId,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'eventTitle': eventTitle,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status.toString().split('.').last, // Stores 'pending', 'confirmed', etc.
      'createdAt': createdAt,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? 'Unknown Vendor',
      eventTitle: map['eventTitle'] ?? 'Untitled Event',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
