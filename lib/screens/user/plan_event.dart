import 'package:flutter/material.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/task_provider.dart';
import 'package:planit_mt/widgets/budget_box.dart';
import 'package:provider/provider.dart';

class PlanEvent extends StatelessWidget {
  const PlanEvent({super.key});

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

    // The checklist now correctly uses the category from confirmed bookings
    final confirmedVendorCategories = bookingProvider.userBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .map((b) => b.vendorCategory)
        .toSet();

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
          ? _buildNoEventState(context)
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
                  _buildTasksSummary(context),
                  const SizedBox(height: 24),
                  _buildBookedVendorsSummary(context),
                ],
              ),
            ),
    );
  }

  Widget _buildNoEventState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration_outlined,
                size: 100, color: Color(0xFFBFA054)),
            const SizedBox(height: 24),
            const Text(
              "Let's get your event started!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Create an event to choose a date, set a budget, and start booking amazing vendors.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createEvent');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Start Planning Your Event'),
            ),
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

  Widget _buildTasksSummary(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final double progress = (taskProvider.totalTasks > 0)
        ? taskProvider.completedTasks / taskProvider.totalTasks
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
            const Text('Tasks Progress',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
                '${taskProvider.completedTasks} of ${taskProvider.totalTasks} completed'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/tasks'),
                child: const Text('Manage Your Tasks'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBookedVendorsSummary(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final activeBookings = bookingProvider.userBookings
        .where((b) => b.status != BookingStatus.declined)
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
            if (bookingProvider.isLoading && activeBookings.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (activeBookings.isEmpty)
              const Text("You haven't booked any vendors for this event yet.")
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeBookings.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final booking = activeBookings[index];
                  return _buildBookingTile(context, booking);
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTile(BuildContext context, BookingModel booking) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (booking.status) {
      case BookingStatus.confirmed:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = "Confirmed";
        break;
      case BookingStatus.pending:
        statusIcon = Icons.hourglass_top;
        statusColor = Colors.orange;
        statusText = "Pending Approval";
        break;
      case BookingStatus.cancelled:
        statusIcon = Icons.cancel;
        statusColor = Colors.grey;
        statusText = "Cancelled by You";
        break;
      default:
        statusIcon = Icons.help_outline;
        statusColor = Colors.grey;
        statusText = "Unknown";
    }

    return ListTile(
      leading: Icon(statusIcon, color: statusColor),
      title: Text(booking.vendorName,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(statusText, style: TextStyle(color: statusColor)),
      // ================== CRITICAL FIX FOR ISSUE #2 ==================
      // This ensures the "Cancel" button appears for pending and confirmed bookings
      // and calls the correct function.
      trailing: (booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.confirmed)
          ? TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancel Booking'),
                    content: Text(
                        'Are you sure you want to cancel the booking with ${booking.vendorName}?'),
                    actions: [
                      TextButton(
                        child: const Text('No'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: const Text('Yes, Cancel'),
                        onPressed: () {
                          // Using context.read for a one-time action
                          context
                              .read<BookingProvider>()
                              .userCancelBooking(booking.bookingId);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
      // ================================================================
    );
  }
}
