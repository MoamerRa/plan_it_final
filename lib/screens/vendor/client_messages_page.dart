import 'package:flutter/material.dart';
import 'package:planit_mt/models/chat_room_model.dart';
import 'package:planit_mt/providers/auth_provider.dart';
import 'package:planit_mt/providers/chat_provider.dart';
import 'package:planit_mt/screens/vendor/chat_page.dart';
import 'package:planit_mt/services/firestore_service.dart'; // We need this for fetching user names
import 'package:provider/provider.dart';

class ClientMessagesPage extends StatefulWidget {
  const ClientMessagesPage({super.key});

  @override
  State<ClientMessagesPage> createState() => _ClientMessagesPageState();
}

class _ClientMessagesPageState extends State<ClientMessagesPage> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to safely access context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendorId = context.read<AuthProvider>().firebaseUser?.uid;
      if (vendorId != null) {
        // Start listening for this vendor's chat rooms
        context.read<ChatProvider>().getChatRooms(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final vendorId = context.watch<AuthProvider>().firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Messages'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: vendorId == null
          ? const Center(child: Text("Please log in to see messages."))
          : StreamBuilder<List<ChatRoom>>(
              stream: chatProvider.chatRoomStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading chats."));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }
                final chatRooms = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = chatRooms[index];
                    return _buildChatRoomTile(context, room, vendorId);
                  },
                );
              },
            ),
    );
  }

  /// Builds a tile for a single chat room.
  /// It fetches the client's name asynchronously.
  Widget _buildChatRoomTile(
      BuildContext context, ChatRoom room, String vendorId) {
    // Find the other participant's ID (the client's ID)
    final clientId =
        room.participants.firstWhere((id) => id != vendorId, orElse: () => '');

    // If for some reason we can't find the other participant, show an error tile.
    if (clientId.isEmpty) {
      return const ListTile(title: Text("Error: Could not load chat"));
    }

    // Use a FutureBuilder to fetch the client's name from their ID
    return FutureBuilder<String?>(
      // We create a helper function to fetch the name to keep the code clean
      future: _getClientName(clientId),
      builder: (context, nameSnapshot) {
        // While the name is loading, show a placeholder
        if (nameSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(title: Text("Loading chat..."));
        }

        final clientName = nameSnapshot.data ?? 'Unknown Client';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(clientName.isNotEmpty ? clientName[0] : '?'),
            ),
            title: Text(clientName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(room.lastMessage,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatRoomId: room.id,
                    recipientName: clientName,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Helper function to get a user's name from their ID.
  /// In a larger app, this might be part of a dedicated user service.
  Future<String?> _getClientName(String userId) async {
    final user = await FirestoreService().getUser(userId);
    return user?.name;
  }
}
