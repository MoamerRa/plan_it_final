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
  // NEW: A set to keep track of which booking is currently being processed.
  final Set<String> _processingBookings = {};

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

  // ================== NEW FUNCTION TO HANDLE BUTTON PRESSES ==================
  Future<void> _handleUpdateStatus(
      BuildContext context, String bookingId, BookingStatus newStatus) async {
    // Show loading state for this specific card
    setState(() {
      _processingBookings.add(bookingId);
    });

    final bookingProvider = context.read<BookingProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await bookingProvider.updateBookingStatus(bookingId, newStatus);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              'Booking ${newStatus == BookingStatus.confirmed ? 'confirmed' : 'declined'} successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hide loading state for this card, regardless of outcome
      if (mounted) {
        setState(() {
          _processingBookings.remove(bookingId);
        });
      }
    }
  }
  // ========================================================================

  @override
  Widget build(BuildContext context) {
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
    final statusColor = _getStatusColor(booking.status);
    final statusText = booking.status.toString().split('.').last.capitalize();
    final isProcessing = _processingBookings.contains(booking.bookingId);

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
                // ================== BUTTONS ARE NOW FUNCTIONAL ==================
                if (isProcessing)
                  const CircularProgressIndicator()
                else if (booking.status == BookingStatus.pending)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _handleUpdateStatus(
                            context, booking.bookingId, BookingStatus.declined),
                        child: const Text('Decline',
                            style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: () => _handleUpdateStatus(context,
                            booking.bookingId, BookingStatus.confirmed),
                        child: const Text('Confirm'),
                      ),
                    ],
                  )
                // ================================================================
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
