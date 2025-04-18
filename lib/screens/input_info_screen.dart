import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import '../models/user_profile.dart';
import '../models/interview_session.dart';
import 'interview_screen.dart';

class InputInfoScreen extends StatefulWidget {
  final UserProfile userProfile;
  final InterviewType interviewType;
  final String? role;

  const InputInfoScreen({
    super.key,
    required this.userProfile,
    required this.interviewType,
    this.role,
  });

  @override
  State<InputInfoScreen> createState() => _InputInfoScreenState();
}

class _InputInfoScreenState extends State<InputInfoScreen> {
  final _cvController = TextEditingController();
  String _language = 'en';
  String? _filePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Additional Information')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CV Summary Section
            const Text('CV Summary or Experience'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cvController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Enter a summary of your experience...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ElevatedButton(
                //   onPressed: _pickFile,
                //   child: const Text('Upload CV'),
                // ),
              ],
            ),
            if (_filePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('File: $_filePath', style: TextStyle(color: Colors.green[700])),
              ),

            const SizedBox(height: 20),

            // Language Selection
            const Text('Interview Language'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'id', label: Text('Bahasa Indonesia')),
              ],
              selected: {_language},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _language = selection.first;
                });
              },
            ),

            const Spacer(),

            // Start Interview Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _startInterview,
              child: const Text('Start Interview'),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
  //   );
  //
  //   if (result != null) {
  //     setState(() {
  //       _filePath = result.files.single.name;
  //     });
  //   }
  // }

  void _startInterview() {
    // Update the user profile with CV summary and language
    final updatedProfile = UserProfile(
      name: widget.userProfile.name,
      age: widget.userProfile.age,
      language: _language,
      cvSummary: _cvController.text.isNotEmpty ? _cvController.text : _filePath,
    );

    // Create a new interview session
    final session = InterviewSession(
      userId: updatedProfile.name, // Using name as userId for simplicity
      type: widget.interviewType,
      role: widget.role,
      startTime: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterviewScreen(
          userProfile: updatedProfile,
          session: session,
        ),
      ),
    );
  }
}