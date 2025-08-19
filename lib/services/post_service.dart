import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart'; // ודא שהנתיב למודל נכון

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // הפניה לקולקציית הפוסטים
  late final CollectionReference<Post> _postsRef;

  PostService() {
    _postsRef = _db.collection('posts').withConverter<Post>(
          fromFirestore: (snapshot, _) => Post.fromMap(snapshot.data()!),
          toFirestore: (post, _) => post.toMap(),
        );
  }

  // פונקציה להבאת כל הפוסטים, מסודרים מהחדש לישן
  Future<List<Post>> getPosts() async {
    try {
      final querySnapshot =
          await _postsRef.orderBy('createdAt', descending: true).get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching posts: $e");
      return [];
    }
  }

  // פונקציה להוספת פוסט חדש
  Future<void> addPost(Post post) async {
    await _postsRef.add(post);
  }
}
