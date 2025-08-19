import 'package:flutter/material.dart';
import 'package:planit_mt/models/user/guest_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/guest_provider.dart';

class GuestListPage extends StatefulWidget {
  const GuestListPage({super.key});

  @override
  State<GuestListPage> createState() => _GuestListPageState();
}

class _GuestListPageState extends State<GuestListPage> {
  @override
  void initState() {
    super.initState();
    // Load guests when the page is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final event = context.read<EventProvider>().activeEvent;
      final user = context.read<AuthProvider>().firebaseUser;
      if (event != null && user != null) {
        context.read<GuestProvider>().fetchGuests(user.uid, event.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final guestProvider = context.watch<GuestProvider>();
    final event = context.watch<EventProvider>().activeEvent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest List'),
      ),
      body: event == null
          ? const Center(child: Text("No active event found."))
          : _buildGuestContent(guestProvider),
      floatingActionButton: event == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddGuestDialog(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildGuestContent(GuestProvider guestProvider) {
    if (guestProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (guestProvider.guests.isEmpty) {
      return const Center(child: Text("No guests added yet."));
    }
    return ListView.builder(
      itemCount: guestProvider.guests.length,
      itemBuilder: (context, index) {
        final guest = guestProvider.guests[index];
        return ListTile(
          title: Text(guest.name),
          subtitle: Text(guest.status.toString().split('.').last),
          trailing: _buildStatusMenu(context, guest),
        );
      },
    );
  }

  Widget _buildStatusMenu(BuildContext context, Guest guest) {
    final event = context.read<EventProvider>().activeEvent!;
    final user = context.read<AuthProvider>().firebaseUser!;
    final guestProvider = context.read<GuestProvider>();

    return PopupMenuButton<GuestStatus>(
      onSelected: (GuestStatus status) {
        guestProvider.updateGuestStatus(user.uid, event.id, guest, status);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<GuestStatus>>[
        const PopupMenuItem<GuestStatus>(
          value: GuestStatus.confirmed,
          child: Text('Confirm'),
        ),
        const PopupMenuItem<GuestStatus>(
          value: GuestStatus.pending,
          child: Text('Set to Pending'),
        ),
        const PopupMenuItem<GuestStatus>(
          value: GuestStatus.declined,
          child: Text('Decline'),
        ),
      ],
    );
  }

  void _showAddGuestDialog(BuildContext context) {
    final controller = TextEditingController();
    final event = context.read<EventProvider>().activeEvent!;
    final user = context.read<AuthProvider>().firebaseUser!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Guest'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Guest Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context
                      .read<GuestProvider>()
                      .addGuest(user.uid, event.id, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
