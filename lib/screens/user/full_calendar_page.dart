import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';

class FullCalendarPage extends StatefulWidget {
  const FullCalendarPage({super.key});

  @override
  State<FullCalendarPage> createState() => _FullCalendarPageState();
}

class _FullCalendarPageState extends State<FullCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    // Connect to the EventProvider to get the real active event
    final eventProvider = context.watch<EventProvider>();
    final EventModel? activeEvent = eventProvider.activeEvent;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Calendar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: activeEvent?.date ?? _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              // Mark the event date on the calendar
              eventLoader: (day) {
                if (activeEvent != null && isSameDay(activeEvent.date, day)) {
                  return [activeEvent]; // Return a list with the event
                }
                return [];
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
                // Style for the marker (dot) on the event day
                markerDecoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Event Details:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Icon(Icons.event_note),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              // Display content based on whether an event exists
              child: activeEvent == null
                  ? _buildNoEventCard(context)
                  : _buildEventDetails(activeEvent),
            )
          ],
        ),
      ),
    );
  }

  /// A card shown when the user has no active event.
  Widget _buildNoEventCard(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No active event found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createEvent');
                },
                child: const Text('Create an Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A widget to display the details of the active event.
  Widget _buildEventDetails(EventModel event) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.celebration, color: Colors.brown),
          title: Text(event.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Your main event is scheduled for this day.'),
        ),
        // You can add more event details here in the future
      ],
    );
  }
}
