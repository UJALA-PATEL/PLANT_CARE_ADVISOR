import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ExpertQNAScreen extends StatefulWidget {
  const ExpertQNAScreen({super.key});

  @override
  ExpertQNAScreenState createState() => ExpertQNAScreenState();
}

class ExpertQNAScreenState extends State<ExpertQNAScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // To hold the list of questions retrieved from Firestore
  List<DocumentSnapshot> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // Fetch questions from Firestore
  Future<void> _loadQuestions() async {
    try {
      final snapshot = await _firestore.collection('questions').get();
      setState(() {
        _questions = snapshot.docs;
      });
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  // Ask question and save to Firestore
  Future<void> _askQuestion() async {
    if (_questionController.text.isNotEmpty) {
      try {
        // Save the question to Firestore
        await _firestore.collection('questions').add({
          'question': _questionController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _questionController.clear();
        _loadQuestions(); // Refresh question list
      } catch (e) {
        print('Error submitting question: $e');
      }
    } else {
      // Show error message if the question is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
    }
  }

  // Reply to a question
  Future<void> _replyToQuestion(String questionId) async {
    if (_replyController.text.isNotEmpty) {
      try {
        // Save the reply to Firestore under the specific questionId
        await _firestore.collection('questions').doc(questionId).collection('replies').add({
          'reply': _replyController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _replyController.clear();
        _loadQuestions(); // Refresh question list to load new replies
      } catch (e) {
        print('Error submitting reply: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reply')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask an Expert')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Ask your question',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _askQuestion,
            child: const Text('Submit Question'),
          ),
          Expanded(
            child: _questions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final questionDoc = _questions[index];
                final questionText = questionDoc['question'];
                final questionId = questionDoc.id;

                return ListTile(
                  title: Text(questionText),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show replies to the question
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('questions')
                            .doc(questionId)
                            .collection('replies')
                            .orderBy('timestamp')
                            .snapshots(),
                        builder: (context, replySnapshot) {
                          if (replySnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          final replies = replySnapshot.data?.docs ?? [];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: replies.map((replyDoc) {
                              final replyText = replyDoc['reply'];
                              return Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text('- $replyText'),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      // TextField to submit a reply
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _replyController,
                          decoration: const InputDecoration(
                            labelText: 'Write a reply',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _replyToQuestion(questionId),
                        child: const Text('Submit Reply'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
