import 'package:flutter/material.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/models/chat_room_model.dart';
import 'package:planit_mt/providers/auth_provider.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendorId = context.read<AuthProvider>().firebaseUser?.uid;
      if (vendorId != null) {
        context.read<BookingProvider>().fetchVendorBookings(vendorId);
        // This now calls the method that provides a Stream
        context.read<ChatProvider>().getChatRooms(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final vendorName = vendorProvider.vendor?.name ?? 'Vendor';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text('Dashboard',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerSection(vendorName),
            const SizedBox(height: 24),
            _buildQuickStats(context),
            const SizedBox(height: 24),
            const Text(
              "Management Tools",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Community',
                  icon: Icons.people_alt_outlined,
                  color: Colors.orange,
                  route: '/vendorcommunity',
                ),
                _buildDashboardCard(
                  context,
                  title: 'Your Bookings',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                  route: '/packages',
                ),
                _buildDashboardCard(
                  context,
                  title: 'Client Messages',
                  icon: Icons.message_outlined,
                  color: Colors.green,
                  route: '/clientmessage',
                ),
                _buildDashboardCard(
                  context,
                  title: 'Add Post',
                  icon: Icons.add_photo_alternate_outlined,
                  color: Colors.purple,
                  route: '/addPost',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerSection(String vendorName) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFBFA054), Color(0xFFD5B04C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vendorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.business_center_outlined,
              size: 50,
              color: Colors.white.withOpacity(0.8),
            )
          ],
        ),
      ),
    );
  }

  /// Builds the quick stats section using data from providers.
  Widget _buildQuickStats(BuildContext context) {
    final bookings = context.watch<BookingProvider>().vendorBookings;
    final chatProvider = context.watch<ChatProvider>();

    final pendingCount =
        bookings.where((b) => b.status == BookingStatus.pending).length;
    final confirmedCount =
        bookings.where((b) => b.status == BookingStatus.confirmed).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(count: pendingCount.toString(), label: 'Pending'),
        // Reverted to using StreamBuilder for chat messages
        StreamBuilder<List<ChatRoom>>(
          stream: chatProvider.chatRoomStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const _StatItem(count: '...', label: 'Messages');
            }
            return _StatItem(
                count: snapshot.data!.length.toString(), label: 'Messages');
          },
        ),
        _StatItem(count: confirmedCount.toString(), label: 'Confirmed'),
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required String route}) {
    return Card(
      color: const Color(0xFFFFF9E6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
