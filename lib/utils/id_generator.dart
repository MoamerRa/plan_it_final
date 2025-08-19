import 'dart:math';

/// Generates a time-based unique ID, suitable for documents like bookings, posts, etc.
/// It combines the current timestamp with a random number to ensure uniqueness.
String generateUniqueId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final randomPart = Random().nextInt(999999).toString().padLeft(6, '0');
  return '$timestamp$randomPart';
}

/// Generates a custom ID with a prefix based on the user's role.
/// Useful for user, vendor, or admin identifiers.
String generateCustomId(String role) {
  final prefix = role == 'vendor'
      ? 'sp'
      : role == 'admin'
          ? 'ad'
          : 'us';

  final randomNumber =
      Random().nextInt(9000) + 1000; // Generates a number between 1000–9999
  return '${prefix}_$randomNumber';
}
