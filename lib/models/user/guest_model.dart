// Enum to represent the status of a guest's RSVP
enum GuestStatus {
  pending,
  confirmed,
  declined,
}

class Guest {
  final String id;
  final String name;
  GuestStatus status;
  String? tableNumber; // Optional

  Guest({
    required this.id,
    required this.name,
    this.status = GuestStatus.pending,
    this.tableNumber,
  });

  // Convert a Guest object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      // Store the enum as a string for readability in Firestore
      'status': status.toString().split('.').last,
      'tableNumber': tableNumber,
    };
  }

  // Create a Guest object from a Firestore document
  factory Guest.fromMap(Map<String, dynamic> map, String documentId) {
    return Guest(
      id: documentId,
      name: map['name'] ?? 'Unknown Name',
      // Convert the string from Firestore back to the enum
      status: GuestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => GuestStatus.pending,
      ),
      tableNumber: map['tableNumber'],
    );
  }
}
