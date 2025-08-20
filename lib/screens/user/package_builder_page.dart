import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planit_mt/models/event_model.dart';
import 'package:planit_mt/models/vendor/app_vendor.dart';
import 'package:planit_mt/providers/auth_provider.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/package_provider.dart';
import 'package:planit_mt/services/booking_service.dart';
import 'package:provider/provider.dart';

/// A screen that displays the user's selected vendor package and allows them to book it.
class PackageBuilderPage extends StatelessWidget {
  const PackageBuilderPage({super.key});

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
          : _buildPackageContent(context, vendors, currencyFormatter),
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

  Widget _buildPackageContent(BuildContext context, List<dynamic> vendors,
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

  // MODIFIED: Logic moved to _onBookPackagePressed
  Widget _buildBookingBar(BuildContext context, PackageProvider packageProvider,
      NumberFormat currencyFormatter) {
    final bookingProvider = context.watch<BookingProvider>();

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
            icon: bookingProvider.isLoading
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
            onPressed: bookingProvider.isLoading
                ? null
                : () => _onBookPackagePressed(context),
          ),
        ],
      ),
    );
  }

  // NEW METHOD: Handles the button press with validation.
  void _onBookPackagePressed(BuildContext context) {
    final EventModel? activeEvent = context.read<EventProvider>().activeEvent;
    final String? userId = context.read<AuthProvider>().firebaseUser?.uid;

    if (activeEvent == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create an event before booking a package.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // If validation passes, call the original handler.
    _handleBookPackage(context, userId, activeEvent);
  }

  /// Handles the final booking process, including an availability check.
  Future<void> _handleBookPackage(
      BuildContext context, String userId, EventModel activeEvent) async {
    final packageProvider = context.read<PackageProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final bookingService = BookingService();

    // --- START OF NEW VALIDATION LOGIC ---
    List<AppVendor> unavailableVendors = [];
    // Check each vendor in the package for availability
    for (final vendor in packageProvider.selectedVendors) {
      final isAvailable = await bookingService.isVendorAvailable(
          vendor.vendorId, activeEvent.date);
      if (!isAvailable) {
        unavailableVendors.add(vendor);
      }
    }

    if (unavailableVendors.isNotEmpty) {
      final names = unavailableVendors.map((v) => v.name).join(', ');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Sorry, the following vendors are no longer available: $names. Please remove them.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return; // Stop the booking process
    }
    // --- END OF NEW VALIDATION LOGIC ---

    final success = await bookingProvider.createBookingsForPackage(
      userId: userId,
      event: activeEvent,
      vendors: packageProvider.selectedVendors,
    );

    if (!context.mounted) return;

    if (success) {
      packageProvider.clearPackage(); // Clear package on success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All booking requests sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back from package page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(bookingProvider.error ?? 'Failed to send booking requests.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
