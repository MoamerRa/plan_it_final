import 'package:flutter/material.dart';
import 'package:planit_mt/models/event_model.dart';
import 'package:planit_mt/providers/auth_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/widgets/navButton.dart';
import 'package:planit_mt/widgets/overview_box.dart';
import 'package:planit_mt/widgets/vendor/vendor_list.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user and event data from providers
    final user = context.watch<UserProvider>().user;
    final eventProvider = context.watch<EventProvider>();
    final activeEvent = eventProvider.activeEvent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // This line removes the back arrow
        automaticallyImplyLeading: false,
        title: const Text('Home',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          // The "Switch to Vendor" button has been removed from here
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
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                  const Text('Explore by Category:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const VendorList(),
                ],
              ),
            ),
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
    if (context.watch<EventProvider>().isLoading) {
      return _buildOverviewSkeletons();
    }
    if (event == null) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No active event. Create one to get started!',
            textAlign: TextAlign.center),
      ));
    }

    final daysLeft = event.date.difference(DateTime.now()).inDays;
    final budgetSpentPercent = event.totalBudget > 0
        ? (event.spentBudget / event.totalBudget * 100).toStringAsFixed(0)
        : "0";
    final totalGuests = event.totalGuests;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OverviewBox(
          title: event.title,
          main: '$daysLeft Days',
          sub: DateFormat('dd/MM/yyyy').format(event.date),
          icon: Icons.event,
        ),
        OverviewBox(
          title: 'Budget',
          main: '$budgetSpentPercent% Spent',
          sub:
              '${event.spentBudget.toStringAsFixed(0)} of ${event.totalBudget.toStringAsFixed(0)}₪',
          icon: Icons.attach_money,
        ),
        OverviewBox(
          title: 'Guests',
          main: '${event.confirmedGuests} Confirmed',
          sub: 'Total: $totalGuests',
          icon: Icons.people,
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
}
