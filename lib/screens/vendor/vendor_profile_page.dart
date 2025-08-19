import 'package:flutter/material.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:provider/provider.dart';
import '../../models/vendor/app_vendor.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart';

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch bookings when the page loads, so we can show stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendorId = context.read<AuthProvider>().firebaseUser?.uid;
      if (vendorId != null) {
        context.read<BookingProvider>().fetchVendorBookings(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final AppVendor? vendor = vendorProvider.vendor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: vendor == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text("Loading Vendor Profile..."),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.read<AuthProvider>().signOut(),
                    child: const Text("Having trouble? Try logging out."),
                  )
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, vendor),
                _buildBody(context, vendor),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppVendor vendor) {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Colors.white,
      elevation: 2,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          vendor.name,
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ),
        background: vendor.imageUrl.isEmpty
            ? Image.network(
                'https://placehold.co/600x400/FFF9E6/BFA054?text=${vendor.name}',
                fit: BoxFit.cover,
              )
            : Image.network(
                vendor.imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://placehold.co/600x400/FFF9E6/BFA054?text=Image+Error',
                    fit: BoxFit.cover,
                  );
                },
              ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit Profile',
          onPressed: () {
            Navigator.pushNamed(context, '/editVendorProfile');
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AppVendor vendor) {
    // Watch the BookingProvider to get booking stats
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.vendorBookings;

    final confirmedCount =
        bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final pendingCount =
        bookings.where((b) => b.status == BookingStatus.pending).length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Business Stats'),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Confirmed', confirmedCount.toString(),
                    Icons.check_circle, Colors.green),
                _buildStatCard('Pending', pendingCount.toString(),
                    Icons.pending, Colors.orange),
                _buildStatCard('Total Views', '1.2K', Icons.visibility,
                    Colors.blue), // Dummy
                _buildStatCard('Rating', vendor.rating.toStringAsFixed(1),
                    Icons.star, Colors.amber),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Description'),
            Text(
              vendor.description.isNotEmpty
                  ? vendor.description
                  : 'No description provided yet.',
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Gallery'),
            vendor.galleryUrls.isEmpty
                ? const Text("No images in the gallery yet.")
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vendor.galleryUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              vendor.galleryUrls[index],
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 60),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
