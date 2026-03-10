import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String plantName;
  final String text;
  final String? imageUrl;
  final int likes;
  final int comments;
  final DateTime timestamp;

  PostModel({
    required this.id,
    required this.userId,
    required this.plantName,
    required this.text,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timestamp,
  });

  factory PostModel.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      plantName: data['plantName'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
