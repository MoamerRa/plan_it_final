
// The EventModel is now upgraded to handle all aspects of a user's event.
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String userId; // Link to the user who owns the event
  final String title;
  final DateTime date;
  final double totalBudget;
  double spentBudget;
  int confirmedGuests;
  int pendingGuests;
  int declinedGuests;

  EventModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.totalBudget,
    this.spentBudget = 0.0,
    this.confirmedGuests = 0,
    this.pendingGuests = 0,
    this.declinedGuests = 0,
  });

  // Helper to get total guests
  int get totalGuests => confirmedGuests + pendingGuests + declinedGuests;

  // Factory constructor to create an EventModel from a Firestore document
  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EventModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Untitled Event',
      date: (map['date'] as Timestamp? ?? Timestamp.now()).toDate(),
      totalBudget: (map['totalBudget'] as num?)?.toDouble() ?? 0.0,
      spentBudget: (map['spentBudget'] as num?)?.toDouble() ?? 0.0,
      confirmedGuests: map['confirmedGuests'] ?? 0,
      pendingGuests: map['pendingGuests'] ?? 0,
      declinedGuests: map['declinedGuests'] ?? 0,
    );
  }

  // Method to convert an EventModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'date': Timestamp.fromDate(date),
      'totalBudget': totalBudget,
      'spentBudget': spentBudget,
      'confirmedGuests': confirmedGuests,
      'pendingGuests': pendingGuests,
      'declinedGuests': declinedGuests,
    };
  }
}
