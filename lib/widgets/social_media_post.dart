import 'package:flutter/material.dart';
import 'package:planit_mt/models/post_model.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class SocialMediaPost extends StatelessWidget {
  final Post post;

  const SocialMediaPost({super.key, required this.post});

  // Helper function to calculate "time ago"
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post.profileImageUrl.isNotEmpty
                      ? post.profileImageUrl
                      : 'https://placehold.co/150'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      // ================== התיקון כאן ==================
                      // We now use the helper function to show dynamic time
                      Text('${post.location} • ${_getTimeAgo(post.createdAt)}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      // ===============================================
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post.postImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
              // Show a loading indicator while the image loads
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              // Show an error icon if the image fails to load
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image,
                    color: Colors.grey, size: 50),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: RichText(
              text: TextSpan(
                style:
                    DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
                children: [
                  TextSpan(
                    text: '${post.username} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),

          // Bottom bar: Likes, Comments, Share
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined,
                        size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text('${post.likes}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline,
                        size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text('${post.comments}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.share, size: 20, color: Colors.grey[700]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
