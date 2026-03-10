import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Correct import path
import 'package:sejjjjj/Community/Services/chat_services.dart';
class LiveSessionsScreen extends StatefulWidget {
  const LiveSessionsScreen({super.key});

  @override
  LiveSessionsScreenState createState() => LiveSessionsScreenState();
}

class LiveSessionsScreenState extends State<LiveSessionsScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  void _sendMessage() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (_messageController.text.isNotEmpty && userId != null) {
      // Fetch user name from Firestore
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      String userName = userDoc.exists ? (userDoc['name'] ?? 'Unknown User') : 'Unknown User';

      // Send message with userId and userName
      await ChatService.sendMessage(
        userId: userId,     // Pass userId
        userName: userName, // Pass userName correctly (match parameter)
        message: _messageController.text,  // Pass message
      );

      _messageController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Sessions Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: ChatService.getMessages(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var data = messages[index].data() as Map<String, dynamic>;
                    bool isMe = data['userId'] == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['message'],
                              style: TextStyle(color: isMe ? Colors.white : Colors.black),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "${data['name'] ?? 'Unknown'}", // Show name instead of userId
                              style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: 'Type a message'),
                    onChanged: (text) {
                      setState(() => _isTyping = text.isNotEmpty);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
