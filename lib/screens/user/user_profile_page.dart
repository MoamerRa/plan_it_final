import 'package:flutter/material.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/task_provider.dart';
import 'package:planit_mt/screens/user/plan_event.dart';
import 'package:provider/provider.dart';
import '../../models/user/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, user),
                _buildBody(context, user),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Colors.white,
      elevation: 2,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          user.name,
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF9E6), Color(0xFFFFF2CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://placehold.co/200x200/EFEFEF/AAAAAA&text=Profile'),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserModel user) {
    final eventProvider = context.watch<EventProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final taskProvider = context.watch<TaskProvider>(); // Get TaskProvider
    final activeEvent = eventProvider.activeEvent;

    // Calculate stats
    final eventsCount = activeEvent != null ? '1' : '0';
    final vendorsBookedCount = bookingProvider.userBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .length
        .toString();
    final totalTasksCount = taskProvider.totalTasks.toString(); // Use task data

    // Calculate completed tasks from checklist
    final confirmedVendorCategories = bookingProvider.userBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .map((b) {
      if (b.vendorName.toLowerCase().contains("hall")) return "Hall";
      if (b.vendorName.toLowerCase().contains("dj")) return "DJ";
      if (b.vendorName.toLowerCase().contains("catering")) return "Catering";
      if (b.vendorName.toLowerCase().contains("photo")) return "Photography";
      return "Other";
    }).toSet();
    int completedChecklistTasks = 0;
    for (var category in confirmedVendorCategories) {
      if (PlanEvent.checklistItems.containsKey(category)) {
        completedChecklistTasks++;
      }
    }
    final checklistTasksDoneCount = completedChecklistTasks.toString();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildStatTile('Events', eventsCount, Icons.celebration,
                        Colors.orange),
                    const Divider(indent: 16, endIndent: 16),
                    _buildStatTile('Vendors Booked', vendorsBookedCount,
                        Icons.store, Colors.blue),
                    const Divider(indent: 16, endIndent: 16),
                    _buildStatTile('Checklist Done', checklistTasksDoneCount,
                        Icons.check_circle, Colors.green),
                    const Divider(indent: 16, endIndent: 16),
                    // REPLACED GUESTS WITH TASKS
                    _buildStatTile('Total Tasks', totalTasksCount,
                        Icons.list_alt, Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
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

  Widget _buildStatTile(
      String title, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
