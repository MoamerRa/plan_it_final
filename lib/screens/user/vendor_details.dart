import 'package:flutter/material.dart';
import 'package:planit_mt/models/event_model.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/chat_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/screens/vendor/chat_page.dart';
import 'package:planit_mt/widgets/vendor_details/vendor_contact.dart';
import 'package:planit_mt/widgets/vendor_details/vendor_description.dart';
import 'package:planit_mt/widgets/vendor_details/vendor_gallery.dart';
import 'package:planit_mt/widgets/vendor_details/vendor_image_header.dart';
import 'package:planit_mt/widgets/vendor_details/vendor_info_section.dart';
import 'package:provider/provider.dart';
import '../../models/vendor/app_vendor.dart';
import '../../providers/auth_provider.dart';

class VendorDetailsPage extends StatelessWidget {
  const VendorDetailsPage({super.key});

  AppVendor _parseVendorFromArgs(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AppVendor) {
      return args;
    }
    throw ArgumentError(
        'VendorDetailsPage requires an AppVendor object in Navigator arguments.');
  }

  @override
  Widget build(BuildContext context) {
    late final AppVendor vendor;
    try {
      vendor = _parseVendorFromArgs(context);
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Failed to open vendor details: $e'),
          ),
        ),
      );
    }

    final userId = context.watch<AuthProvider>().firebaseUser?.uid;
    final EventModel? activeEvent = context.watch<EventProvider>().activeEvent;
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(vendor.name, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          VendorImageHeader(image: vendor.imageUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VendorInfoSection(
                  name: vendor.name,
                  category: vendor.category,
                  price: vendor.price,
                  rating: vendor.rating,
                ),
                const Divider(height: 32),
                VendorDescription(description: vendor.description),
                const SizedBox(height: 24),
                VendorGallery(images: vendor.galleryUrls),
                const SizedBox(height: 24),
                VendorContact(phone: vendor.phone, email: vendor.email),
                const SizedBox(height: 24),
                if (userId != null)
                  _buildActionButtons(
                      context, userId, vendor, activeEvent, bookingProvider)
                else
                  const Center(
                    child:
                        Text('Please sign in to book or message this vendor.'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      String userId,
      AppVendor vendor,
      EventModel? activeEvent,
      BookingProvider bookingProvider) {
    return Center(
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: bookingProvider.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.calendar_today),
            label: Text(
              bookingProvider.isLoading ? 'Processing...' : 'Book Now',
            ),
            onPressed: (activeEvent == null || bookingProvider.isLoading)
                ? null // Disable button if no active event or already loading
                : () async {
                    final success = await bookingProvider.createBookingRequest(
                      userId: userId,
                      vendorId: vendor.vendorId,
                      vendorName: vendor.name,
                      eventId: activeEvent.id,
                      eventTitle: activeEvent.title,
                      bookingDate: activeEvent.date,
                    );

                    if (!context.mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking request sent successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(bookingProvider.error ??
                              'Failed to send booking request.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          if (activeEvent == null)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'You must create an event to book a vendor.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.message_outlined),
            label: const Text('Send Message'),
            onPressed: () async {
              try {
                final chatProvider = context.read<ChatProvider>();
                final chatRoomId = await chatProvider.getOrCreateChatRoom(
                    userId, vendor.vendorId);
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      chatRoomId: chatRoomId,
                      recipientName: vendor.name,
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to open chat: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
