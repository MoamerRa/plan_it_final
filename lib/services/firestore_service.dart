import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:planit_mt/models/admin/app_admin.dart';
import 'package:planit_mt/models/report_model.dart';
import 'package:planit_mt/models/user/guest_model.dart';
import 'package:planit_mt/models/booking_model.dart'; // Corrected import usage
import 'package:planit_mt/models/chat_message_model.dart';
import 'package:planit_mt/models/chat_room_model.dart';
import 'package:planit_mt/models/event_model.dart';
import 'package:planit_mt/models/expense_model.dart';
import 'package:planit_mt/models/user/user_model.dart';
import 'package:planit_mt/models/vendor/app_vendor.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Booking Management ---

  /// Gets a stream of all bookings for a specific vendor.
  Stream<List<BookingModel>> getVendorBookings(String vendorId) {
    return _db
        .collection('bookings')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()))
            .toList());
  }

  /// Updates the status of a specific booking.
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await _db
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status.toString().split('.').last});
  }

  Future<void> createBooking(
      {required EventModel event, required AppVendor vendor}) async {
    final newBookingRef = _db.collection('bookings').doc();
    final booking = BookingModel(
      bookingId: newBookingRef.id,
      eventId: event.id,
      userId: event.userId,
      vendorId: vendor.vendorId,
      vendorName: vendor.name,
      eventTitle: event.title,
      bookingDate: event.date,
      createdAt: Timestamp.now(),
      status: BookingStatus.pending,
    );
    await newBookingRef.set(booking.toMap());
  }

  // --- Chat Management ---
  Stream<List<ChatRoom>> getChatRooms(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }

  Future<String> getOrCreateChatRoom(String userId, String vendorId) async {
    final participants = [userId, vendorId]..sort();
    final chatRoomQuery = await _db
        .collection('chats')
        .where('participants', isEqualTo: participants)
        .limit(1)
        .get();

    if (chatRoomQuery.docs.isNotEmpty) {
      return chatRoomQuery.docs.first.id;
    } else {
      final newChatRoomRef = _db.collection('chats').doc();
      await newChatRoomRef.set({
        'participants': participants,
        'lastMessage': '',
        'lastMessageTimestamp': Timestamp.now(),
      });
      return newChatRoomRef.id;
    }
  }

  Future<void> sendMessage(
      String chatRoomId, String text, String senderId) async {
    final messageData = {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
    };
    await _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    await _db.collection('chats').doc(chatRoomId).update({
      'lastMessage': text,
      'lastMessageTimestamp': Timestamp.now(),
    });
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // --- Expense Management ---
  Future<List<Expense>> getExpenses(String userId, String eventId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  Future<void> addExpense(
      String userId, String eventId, Expense expense) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .add(expense.toMap());
  }

  Future<void> deleteExpense(
      String userId, String eventId, String expenseId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Future<void> updateEventSpentBudget(
      String userId, String eventId, double newTotal) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .update({'spentBudget': newTotal});
  }

  // --- Guest Management ---
  Future<List<Guest>> getGuests(String userId, String eventId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .get();
    return snapshot.docs
        .map((doc) => Guest.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addGuest(String userId, String eventId, String name) async {
    final newGuest = Guest(id: '', name: name);
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .add(newGuest.toMap());
  }

  Future<void> updateGuest(String userId, String eventId, Guest guest) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .doc(guest.id)
        .update(guest.toMap());
  }

  Future<void> deleteGuest(
      String userId, String eventId, String guestId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .doc(guestId)
        .delete();
  }

  // --- Other Functions ---
  Future<void> saveUserEvent(EventModel event) async {
    await _db
        .collection('users')
        .doc(event.userId)
        .collection('events')
        .doc(event.id)
        .set(event.toMap(), SetOptions(merge: true));
  }

  Future<EventModel?> getActiveUserEvent(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('events')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return EventModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting active user event: $e");
      }
      return null;
    }
  }

  Future<List<AppVendor>> getApprovedVendors() async {
    try {
      final querySnapshot = await _db
          .collection('vendors')
          .where('isApproved', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppVendor.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching approved vendors: $e");
      }
      return [];
    }
  }

  Future<void> createVendor(AppVendor vendor) async {
    await _db.collection('vendors').doc(vendor.vendorId).set(vendor.toJson());
  }

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final docSnapshot = await _db.collection('users').doc(uid).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return UserModel.fromMap(docSnapshot.data()!);
    }
    return null;
  }

  Future<AppVendor?> getVendor(String uid) async {
    final docSnapshot = await _db.collection('vendors').doc(uid).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return AppVendor.fromJson(docSnapshot.data()!);
    }
    return null;
  }

  Future<void> updateVendorProfile(
      String uid, Map<String, dynamic> data) async {
    await _db.collection('vendors').doc(uid).update(data);
  }

  // --- Report Management ---

  /// Creates a new report document in the top-level 'reports' collection.
  Future<void> createReport(Report report) async {
    await _db.collection('reports').add(report.toMap());
  }

  /// Gets a real-time stream of all reports, ordered from newest to oldest.
  Stream<List<Report>> getReports() {
    return _db
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList());
  }

  /// Updates the status of a specific report (e.g., from 'open' to 'resolved').
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    await _db
        .collection('reports')
        .doc(reportId)
        .update({'status': status.toString().split('.').last});
  }

  Future<void> createAdmin(AdminModel admin) async {
    // Note: The collection is 'admin' (singular) to match the login logic.
    await _db.collection('admin').doc(admin.id).set(admin.toMap());
  }

  /// Checks if an email or phone number already exists across all user collections.
  /// Returns an error message string if a duplicate is found, otherwise null.
  Future<String?> checkIfUserExists(
      {required String email, required String phone}) async {
    const collections = ['users', 'vendors', 'admin'];
    for (final collection in collections) {
      // Check for email
      final emailQuery = await _db
          .collection(collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (emailQuery.docs.isNotEmpty) {
        return 'An account with this email already exists.';
      }

      // Check for phone
      final phoneQuery = await _db
          .collection(collection)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (phoneQuery.docs.isNotEmpty) {
        return 'An account with this phone number already exists.';
      }
    }
    return null; // No duplicates found
  }

  /// Finds a user by identifier (phone or case-insensitive name).
  Future<Map<String, String?>?> findUserEmailAndRole(String identifier) async {
    const collectionsToSearch = {
      'users': 'user',
      'vendors': 'vendor',
      'admin': 'admin',
    };

    for (var entry in collectionsToSearch.entries) {
      final collectionName = entry.key;
      final role = entry.value;

      // Query by phone number first
      var querySnapshot = await _db
          .collection(collectionName)
          .where('phone', isEqualTo: identifier)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return {'email': data['email'], 'role': role};
      }

      // If not found by phone, query by the lowercase name field
      querySnapshot = await _db
          .collection(collectionName)
          .where('name_lowercase', isEqualTo: identifier.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return {'email': data['email'], 'role': role};
      }
    }
    return null;
  }
}
