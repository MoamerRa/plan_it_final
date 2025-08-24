import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planit_mt/models/vendor/app_vendor.dart';
import 'package:planit_mt/providers/auth_provider.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/package_provider.dart';
import 'package:provider/provider.dart';

class PackageBuilderPage extends StatefulWidget {
  const PackageBuilderPage({super.key});

  @override
  State<PackageBuilderPage> createState() => _PackageBuilderPageState();
}

class _PackageBuilderPageState extends State<PackageBuilderPage> {
  // Local loading state for the booking button to ensure immediate UI feedback
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final vendors = packageProvider.selectedVendors;
    final currencyFormatter =
        NumberFormat.currency(locale: 'he_IL', symbol: '₪', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Event Package'),
        actions: [
          if (vendors.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Package',
              onPressed: () => context.read<PackageProvider>().clearPackage(),
            )
        ],
      ),
      body: vendors.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                _buildEventDateHeader(context),
                const Divider(height: 1),
                Expanded(
                  child:
                      _buildPackageContent(context, vendors, currencyFormatter),
                ),
              ],
            ),
      bottomNavigationBar: vendors.isEmpty
          ? null
          : _buildBookingBar(context, packageProvider, currencyFormatter),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_shopping_cart, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Your package is empty.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add vendors from the "Explore" page.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back to Exploring'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDateHeader(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final activeEvent = eventProvider.activeEvent;

    if (activeEvent == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Booking for Event Date:",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(activeEvent.date),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageContent(BuildContext context, List<AppVendor> vendors,
      NumberFormat currencyFormatter) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(vendor.imageUrl.isNotEmpty
                  ? vendor.imageUrl
                  : 'https://placehold.co/100'),
            ),
            title: Text(vendor.name),
            subtitle: Text(vendor.category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currencyFormatter.format(vendor.price),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: () {
                    context.read<PackageProvider>().removeVendor(vendor);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingBar(BuildContext context, PackageProvider packageProvider,
      NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Price:', style: TextStyle(color: Colors.grey)),
              Text(
                currencyFormatter.format(packageProvider.totalPrice),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton.icon(
            icon: _isBooking
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.calendar_today),
            label: const Text('Book Package'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _isBooking ? null : _onBookPackagePressed,
          ),
        ],
      ),
    );
  }

  Future<void> _onBookPackagePressed() async {
    // Show loading indicator immediately and prevent double-clicks
    setState(() {
      _isBooking = true;
    });

    // ================== FIX FOR LINT WARNING ==================
    // Capture context-dependent objects BEFORE the async gap.
    final packageProvider = context.read<PackageProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final eventProvider = context.read<EventProvider>();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // ==========================================================

    try {
      final activeEvent = eventProvider.activeEvent;
      final userId = authProvider.firebaseUser?.uid;

      if (activeEvent == null || userId == null) {
        throw Exception('Error: Could not find active event or user.');
      }

      // Create the booking requests
      final success = await bookingProvider.createBookingsForPackage(
        userId: userId,
        event: activeEvent,
        vendors: packageProvider.selectedVendors,
      );

      if (!success) {
        throw Exception(
            bookingProvider.error ?? 'Failed to send booking requests.');
      }

      // --- This is the key part ---
      // Clear the package only AFTER the requests were sent successfully.
      packageProvider.clearPackage();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('All booking requests sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate the user back to the home screen to see the pending bookings.
      navigator.pushNamedAndRemoveUntil('/userHome', (route) => false);
    } catch (e) {
      // Now it's safe to use 'messenger' here because it was captured before the await.
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Always hide loading indicator, even if an error occurred.
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }
}
