import 'package:flutter/material.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/widgets/budget_box.dart';
import 'package:planit_mt/widgets/guest_pie_chart.dart';
import 'package:provider/provider.dart';

class PlanEvent extends StatelessWidget {
  const PlanEvent({super.key});

  // The checklist items. This is static UI data.
  static const Map<String, String> checklistItems = {
    'Hall': 'Book a venue',
    'Catering': 'Finalize catering',
    'DJ': 'Hire a DJ',
    'Photography': 'Book a photographer',
    'Clothing': 'Arrange outfits',
    'Decor': 'Plan decorations',
    'Makeup': 'Schedule makeup artist',
  };

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final activeEvent = eventProvider.activeEvent;

    // Get categories of confirmed vendors
    final confirmedVendorCategories = bookingProvider.userBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .map((b) {
      // We need to fetch the vendor to get their category.
      // This is a simplification; in a real app, you'd fetch this data more efficiently.
      // For now, we'll assume the vendor's name implies their category for the UI.
      // A better approach is to store the category in the booking model itself.
      // For this example, we'll just use a placeholder logic.
      if (b.vendorName.toLowerCase().contains("hall")) return "Hall";
      if (b.vendorName.toLowerCase().contains("dj")) return "DJ";
      if (b.vendorName.toLowerCase().contains("catering")) return "Catering";
      if (b.vendorName.toLowerCase().contains("photo")) return "Photography";
      return "Other";
    }).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Event Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: activeEvent == null
          ? const Center(child: Text("Create an event to start planning!"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChecklistSection(context, confirmedVendorCategories),
                  const SizedBox(height: 16),
                  BudgetBox(
                    totalBudget: activeEvent.totalBudget,
                    spentBudget: activeEvent.spentBudget,
                    onTap: () => Navigator.pushNamed(context, '/budget'),
                  ),
                  const SizedBox(height: 24),
                  const Card(
                    color: Color(0xFFFFF9E6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: GuestPieChart(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildBookedVendorsSummary(context),
                ],
              ),
            ),
    );
  }

  Widget _buildChecklistSection(
      BuildContext context, Set<String> confirmedCategories) {
    int completedTasks = 0;
    for (var category in confirmedCategories) {
      if (checklistItems.containsKey(category)) {
        completedTasks++;
      }
    }
    final progress = checklistItems.isNotEmpty
        ? completedTasks / checklistItems.length
        : 0.0;

    return Card(
      color: const Color(0xFFFFF9E6),
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Checklist',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('$completedTasks of ${checklistItems.length} completed'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 16),
            ...checklistItems.entries.map((entry) {
              final isCompleted = confirmedCategories.contains(entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isCompleted ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value,
                      style: TextStyle(
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookedVendorsSummary(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final confirmedBookings = bookingProvider.userBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .toList();

    return Card(
      color: const Color(0xFFFFF9E6),
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booked Vendors',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            if (bookingProvider.isLoading && confirmedBookings.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (confirmedBookings.isEmpty)
              const Text("You haven't booked any vendors for this event yet.")
            else ...[
              ...confirmedBookings.map((b) => ListTile(
                    leading:
                        const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(b.vendorName),
                    subtitle: Text(b.eventTitle),
                  )),
            ]
          ],
        ),
      ),
    );
  }
}
