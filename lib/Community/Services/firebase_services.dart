import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ **Current User ID Fetch Karne Ka Function**
  // ✅ Current User ID Fetch Karne Ka Function
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // ✅ **Post Add Karne Ka Function**
  static Future<void> addPost({required String text, String? plantName, String? mediaUrl, String? userId}) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print("Error: User not logged in!");
        return;
      }

      await _firestore.collection('posts').add({
        'userId': userId,
        'text': text,
        'plantName': plantName ?? "",
        'mediaUrl': mediaUrl ?? "",
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding post: $e");
    }
  }

  // ✅ **Post Ko Like Karne Ka Function**
  static Future<void> likePost(String postId) async {
    try {
      DocumentReference postRef = _firestore.collection('posts').doc(postId);
      DocumentSnapshot postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        int currentLikes = (postSnapshot.data() as Map<String, dynamic>)['likes'] ?? 0;
        await postRef.update({'likes': currentLikes + 1});
      }
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  // ✅ **Comment Add Karne Ka Function**
  static Future<void> addComment(String postId, String comment) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print("Error: User not logged in!");
        return;
      }

      await _firestore.collection('posts').doc(postId).collection('comments').add({
        'userId': userId,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  // ✅ **Comments Fetch Karne Ka Function**
  static Stream<List<String>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['comment'] as String).toList();
    });
  }

  // ✅ **Posts Fetch Karne Ka Function**
  static Stream<QuerySnapshot> getPosts() {
    return _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots();
  }
}
