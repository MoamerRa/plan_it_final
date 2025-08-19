import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String username;
  final String profileImageUrl;
  final String location;
  // The 'timeAgo' field has been removed for better practice.
  // It will be calculated dynamically in the UI.
  final String postImageUrl;
  final String reactionUsers;
  final String caption;
  final int likes;
  final int comments;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.location,
    required this.postImageUrl,
    required this.reactionUsers,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      location: map['location'] ?? '',
      postImageUrl: map['postImageUrl'] ?? '',
      reactionUsers: map['reactionUsers'] ?? '',
      caption: map['caption'] ?? '',
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'postImageUrl': postImageUrl,
      'reactionUsers': reactionUsers,
      'caption': caption,
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
