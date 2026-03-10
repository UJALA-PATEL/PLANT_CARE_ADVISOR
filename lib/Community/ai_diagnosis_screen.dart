import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Services/ai_diagnosis_services.dart';
import 'Services/firebase_services.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  DiagnosisScreenState createState() => DiagnosisScreenState();
}

class DiagnosisScreenState extends State<DiagnosisScreen> {
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _solutionController = TextEditingController();
  bool _isProcessing = false;
  List<Map<String, dynamic>> _diagnoses = [];

  @override
  void initState() {
    super.initState();
    _fetchDiagnoses();
  }

  Future<void> _fetchDiagnoses() async {
    try {
      List<Map<String, dynamic>> diagnoses = await AiDiagnosisService.getUserDiagnoses();
      if (mounted) {
        setState(() => _diagnoses = diagnoses);
      }
    } catch (e) {
      print("🔥 Error fetching diagnoses: $e");
    }
  }

  Future<void> _shareDiagnosis() async {
    if (_problemController.text.isEmpty || _solutionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add problem & solution details!")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in!")),
        );
        return;
      }

      await FirebaseService.addPost(
        userId: userId,
        text: "Problem: ${_problemController.text}\nSolution: ${_solutionController.text}",
        mediaUrl: "", // No image
        plantName: "User Diagnosis",
      );

      _problemController.clear();
      _solutionController.clear();
      _fetchDiagnoses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diagnosis shared successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plant Diagnosis")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _problemController,
                decoration: const InputDecoration(labelText: "Describe the problem..."),
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _solutionController,
                decoration: const InputDecoration(labelText: "How did you solve it?"),
                maxLines: 3,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _shareDiagnosis,
              icon: const Icon(Icons.share),
              label: _isProcessing ? const Text("Processing...") : const Text("Share Diagnosis"),
            ),
            const SizedBox(height: 20),
            const Text("Your Diagnoses:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _diagnoses.length,
              itemBuilder: (context, index) {
                final diagnosis = _diagnoses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(diagnosis['diagnosis'] ?? "No diagnosis"),
                    subtitle: Text(diagnosis['userComment'] ?? "No comment"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
