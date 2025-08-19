import 'package:flutter/material.dart';
import '../../models/vendor/client_message.dart';

class ClientMessageCard extends StatelessWidget {
  final ClientMessage message;

  const ClientMessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber.shade400,
          child: Text(
            message.clientName[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          message.clientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${message.eventTitle} • ${message.date}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          // בעתיד: מעבר לצ'אט מלא
        },
      ),
    );
  }
}
