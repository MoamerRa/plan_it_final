import 'package:flutter/material.dart';
import 'package:planit_mt/providers/chat_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/package_provider.dart';
import 'package:planit_mt/screens/vendor/chat_page.dart';
import 'package:planit_mt/services/booking_service.dart';
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
          // --- FIX: Passed the vendor name to the header for the placeholder ---
          VendorImageHeader(image: vendor.imageUrl, vendorName: vendor.name),
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
                  _buildActionButtons(context, userId, vendor)
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
      BuildContext context, String userId, AppVendor vendor) {
    final packageProvider = context.watch<PackageProvider>();
    final isAdded = packageProvider.isVendorInPackage(vendor);
    final activeEvent = context.watch<EventProvider>().activeEvent;

    if (activeEvent == null) {
      return Center(
        child: Column(
          children: [
            const ElevatedButton(
              onPressed: null,
              child: Text('Create an Event to Add Vendor'),
            ),
            const SizedBox(height: 16),
            _buildMessageButton(context, userId, vendor),
          ],
        ),
      );
    }

    return FutureBuilder<bool>(
      future:
          BookingService().isVendorAvailable(vendor.vendorId, activeEvent.date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isAvailable = snapshot.data ?? true;

        return Center(
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: isAvailable
                    ? Icon(isAdded ? Icons.check : Icons.add_shopping_cart)
                    : const Icon(Icons.block),
                label: Text(isAvailable
                    ? (isAdded ? 'Added to Package' : 'Add to Package')
                    : 'Booked on this date'),
                onPressed: !isAvailable
                    ? null
                    : () {
                        if (isAdded) {
                          packageProvider.removeVendor(vendor);
                        } else {
                          packageProvider.addVendor(vendor);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isAvailable
                      ? Colors.red.shade300
                      : (isAdded
                          ? Colors.grey
                          : Theme.of(context).primaryColor),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              _buildMessageButton(context, userId, vendor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageButton(
      BuildContext context, String userId, AppVendor vendor) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.message_outlined),
      label: const Text('Send Message'),
      onPressed: () async {
        try {
          final chatProvider = context.read<ChatProvider>();
          final chatRoomId =
              await chatProvider.getOrCreateChatRoom(userId, vendor.vendorId);
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
    );
  }
}
