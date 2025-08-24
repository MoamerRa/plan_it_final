import 'package:flutter/material.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/models/event_model.dart';
import 'package:planit_mt/providers/auth_provider.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/task_provider.dart';
import 'package:planit_mt/widgets/navButton.dart';
import 'package:planit_mt/widgets/overview_box.dart';
import 'package:planit_mt/widgets/vendor/vendor_list.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    await _refreshData(); // Use the refresh method for initial load
  }

  // ================== FIX FOR ISSUE #1 (Part 1) ==================
  // This method will be used for both initial load and pull-to-refresh.
  Future<void> _refreshData() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final taskProvider = context.read<TaskProvider>();

    final user = authProvider.firebaseUser;
    if (user != null) {
      // Fetch all data sources concurrently for faster loading.
      await Future.wait([
        Future.microtask(() => eventProvider.listenToUserEvent(user.uid)),
        Future.microtask(() => bookingProvider.fetchUserBookings(user.uid)),
        Future.microtask(() => taskProvider.fetchTasks()),
      ]);

      // A short delay to allow the listener to get the first event
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && eventProvider.activeEvent == null) {
        _showCreateEventDialog();
      }
    }
  }
  // ================================================================

  void _showCreateEventDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Welcome to PlanIt!"),
          content: const Text(
              "To start planning and exploring vendors, you need to create an event first."),
          actions: <Widget>[
            TextButton(
              child: const Text("Create Event"),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                // No need to check result, the stream will update the UI.
                await Navigator.pushNamed(context, '/createEvent');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final eventProvider = context.watch<EventProvider>();
    final activeEvent = eventProvider.activeEvent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text('Home',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          // ================== FIX FOR ISSUE #1 (Part 2) ==================
          // Wrap the body with RefreshIndicator.
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Important for refresh
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerSection(user.name),
                    const SizedBox(height: 20),
                    _buildEventOverview(context, activeEvent),
                    const SizedBox(height: 24),
                    const NavButton(
                        route: '/userplan',
                        title: "Let's Plan An Event",
                        icon: Icons.calendar_today_outlined),
                    const SizedBox(height: 16),
                    const NavButton(
                        route: '/community',
                        title: "Posts from Vendors!",
                        icon: Icons.image_outlined),
                    const SizedBox(height: 16),
                    const NavButton(
                        route: '/recommend',
                        title: "Get Event Package Recommendations",
                        icon: Icons.auto_awesome_outlined),
                    const SizedBox(height: 24),
                    _buildBookedVendors(context),
                    const SizedBox(height: 24),
                    const Text('Explore by Category:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const VendorList(),
                  ],
                ),
              ),
            ),
      // ================================================================
    );
  }

  Widget _headerSection(String username) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/up.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hello, $username!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'DancingScript',
                color: Color(0xFF1E2742),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventOverview(BuildContext context, EventModel? event) {
    // ================== FIX FOR ISSUE #1 (Part 3) ==================
    // Ensure we are WATCHING the providers here so the UI rebuilds on change.
    final eventProvider = context.watch<EventProvider>();
    final taskProvider = context.watch<TaskProvider>();
    // ================================================================
    final liveEvent = eventProvider.activeEvent;

    if (eventProvider.isLoading && liveEvent == null) {
      return _buildOverviewSkeletons();
    }
    if (liveEvent == null) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No active event. Create one to get started!',
            textAlign: TextAlign.center),
      ));
    }

    final daysLeft = liveEvent.date.difference(DateTime.now()).inDays;
    final budgetSpentPercent = liveEvent.totalBudget > 0
        ? (liveEvent.spentBudget / liveEvent.totalBudget * 100)
            .toStringAsFixed(0)
        : "0";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OverviewBox(
          title: liveEvent.title,
          main: '$daysLeft Days',
          sub: DateFormat('dd/MM/yyyy').format(liveEvent.date),
          icon: Icons.event,
        ),
        OverviewBox(
          title: 'Budget',
          main: '$budgetSpentPercent% Spent',
          sub:
              '${liveEvent.spentBudget.toStringAsFixed(0)} of ${liveEvent.totalBudget.toStringAsFixed(0)}₪',
          icon: Icons.attach_money,
        ),
        OverviewBox(
          title: 'Tasks',
          main: '${taskProvider.completedTasks} Done',
          sub: 'Total: ${taskProvider.totalTasks}',
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _buildOverviewSkeletons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
          3,
          (_) => Container(
                width: 110,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              )),
    );
  }

  Widget _buildBookedVendors(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final confirmedBookings = bookingProvider.userBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .toList();

    if (bookingProvider.isLoading && confirmedBookings.isEmpty) {
      return const SizedBox.shrink();
    }

    if (confirmedBookings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Booked Vendors:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: confirmedBookings.length,
            itemBuilder: (context, index) {
              final booking = confirmedBookings[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 10),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.store, color: Colors.green, size: 30),
                        const SizedBox(height: 8),
                        Text(
                          booking.vendorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          booking.eventTitle,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
