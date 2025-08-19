import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/providers/auth_provider.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:provider/provider.dart';

class YourPackagesPage extends StatefulWidget {
  const YourPackagesPage({super.key});

  @override
  State<YourPackagesPage> createState() => _YourPackagesPageState();
}

class _YourPackagesPageState extends State<YourPackagesPage> {
  @override
  void initState() {
    super.initState();
    // Fetch bookings when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendorId = context.read<AuthProvider>().firebaseUser?.uid;
      if (vendorId != null) {
        context.read<BookingProvider>().fetchVendorBookings(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 'watch' listens for changes in the provider
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.vendorBookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Bookings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text("No booking requests yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _buildBookingCard(context, booking);
                  },
                ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    // 'read' is used for one-time actions inside buttons
    final bookingProvider = context.read<BookingProvider>();
    final statusColor = _getStatusColor(booking.status);
    final statusText = booking.status.toString().split('.').last.capitalize();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.eventTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
                'Date: ${DateFormat('dd/MM/yyyy').format(booking.bookingDate)}'),
            // In a real app, you'd fetch the client's name from the userId
            Text('Client ID: ${booking.userId.substring(0, 6)}...'),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status:', style: TextStyle(color: Colors.grey)),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Show action buttons only if the booking is pending
                if (booking.status == BookingStatus.pending)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => bookingProvider.updateBookingStatus(
                            booking.bookingId, BookingStatus.declined),
                        child: const Text('Decline',
                            style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: () => bookingProvider.updateBookingStatus(
                            booking.bookingId, BookingStatus.confirmed),
                        child: const Text('Confirm'),
                      ),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
      default:
        return Colors.orange;
    }
  }
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
