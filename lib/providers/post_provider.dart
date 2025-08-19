import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  // Constructor is now empty to implement lazy loading.
  PostProvider();

  Future<void> fetchPosts() async {
    // To ensure a fresh list is always fetched on manual refresh,
    // we can remove the isNotEmpty check or handle state more granularly.
    // For now, let's clear the list to allow refresh.
    _posts = [];
    _isLoading = true;
    notifyListeners();

    _posts = await _postService.getPosts();
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> addPost({
    required String caption,
    required File imageFile,
    required String username,
    required String profileImageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return "User not logged in.";
    }

    final imageUrl = await _storageService.uploadPostImage(
      imageFile: imageFile,
      uid: user.uid,
    );

    if (imageUrl == null) {
      _isLoading = false;
      notifyListeners();
      return "Failed to upload image.";
    }

    final newPost = Post(
      id: '', // Firestore will generate this
      username: username,
      profileImageUrl: profileImageUrl,
      location: 'Israel',
      postImageUrl: imageUrl,
      caption: caption,
      likes: 0,
      comments: 0,
      reactionUsers: '',
      createdAt: DateTime.now(),
    );

    try {
      await _postService.addPost(newPost);
      // Fetch posts again to show the new one immediately.
      await fetchPosts();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
