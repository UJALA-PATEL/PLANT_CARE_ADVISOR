import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const PostCard(this.doc, {super.key});

  @override
  Widget build(BuildContext context) {
    var data = doc.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        title: Text(data['plantName'] ?? "Unknown Plant"),
        subtitle: Text(data['text'] ?? ""),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.thumb_up, color: Colors.blue),
            const SizedBox(width: 5),
            Text(data['likes'].toString()),
          ],
        ),
      ),
    );
  }
}
