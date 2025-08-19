import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/social_media_post.dart';
import 'add_post_page.dart';

class VendorCommunityPage extends StatelessWidget {
  const VendorCommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in PostProvider
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Community'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Manual refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Feed',
            onPressed: () {
              context.read<PostProvider>().fetchPosts();
            },
          ),
        ],
      ),
      // ================== התיקון כאן ==================
      // The body now dynamically builds based on the provider's state.
      body: postProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : postProvider.posts.isEmpty
              ? const Center(
                  child: Text(
                    'No posts yet. Be the first to post!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              // Use RefreshIndicator for pull-to-refresh functionality
              : RefreshIndicator(
                  onRefresh: () => context.read<PostProvider>().fetchPosts(),
                  child: ListView.builder(
                    itemCount: postProvider.posts.length,
                    itemBuilder: (context, index) {
                      final post = postProvider.posts[index];
                      return SocialMediaPost(post: post);
                    },
                  ),
                ),
      // ===============================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPostPage()),
          );
        },
        label: const Text('Add Post'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFBFA054),
        foregroundColor: Colors.white,
      ),
    );
  }
}
