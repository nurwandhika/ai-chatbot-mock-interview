import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/interview_session.dart';
import '../models/user_profile.dart';
import '../services/cv_parser_service.dart';
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
  String? _fileName;
  final CvParserService _cvParserService = CvParserService();
  bool _isInputValid = false;

  @override
  void initState() {
    super.initState();
    _cvController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _cvController.removeListener(_validateInput);
    _cvController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isInputValid = _cvController.text.isNotEmpty || _fileName != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Additional Information')),
      // Prevent screen resizing when keyboard appears
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          // Use SingleChildScrollView to allow scrolling when keyboard appears
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    kToolbarHeight - // Account for AppBar
                    40, // Account for padding
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top content section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'CV Summary or Experience *',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cvController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                    _fileName == null
                                        ? 'Enter a summary of your experience...'
                                        : 'File uploaded, text input optional',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _pickFile,
                            child: const Text('Upload CV'),
                          ),
                        ],
                      ),
                      if (_fileName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'File: $_fileName',
                                  style: TextStyle(color: Colors.green[700]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _fileName = null;
                                    _filePath = null;
                                    _validateInput();
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Language Selection
                      const Text(
                        'Interview Language',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'en', label: Text('English')),
                          ButtonSegment(
                            value: 'id',
                            label: Text('Bahasa Indonesia'),
                          ),
                        ],
                        selected: {_language},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _language = selection.first;
                          });
                        },
                      ),
                    ],
                  ),

                  // Button stays at bottom
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      onPressed: _isInputValid ? _startInterview : null,
                      child: const Text('Start Interview'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      // Basic file picking with minimal options
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _filePath = result.files.single.path;
          _validateInput();
        });
      }
    } catch (e, stackTrace) {
      print('FILE PICKER ERROR: $e');
      print('STACK TRACE: $stackTrace');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _startInterview() async {
    String? cvSummary = _cvController.text;
    bool parsedSuccessfully = false;

    // Show loading indicator
    setState(() {
      _isInputValid = false; // Disable button while loading
    });

    // If there's a file path, try to parse it
    if (_filePath != null) {
      try {
        debugPrint('CV PARSER: Starting to parse file: $_fileName');

        // Parse the file content
        final fileContent = await _cvParserService.parseFromFile(_filePath!);

        if (fileContent != null) {
          debugPrint('CV PARSER: Successfully read file content (${fileContent.length} chars)');

          // Extract summary from the parsed content
          final summary = await _cvParserService.extractSummary(fileContent);

          if (summary != null) {
            debugPrint('CV PARSER: Successfully extracted summary (${summary.length} chars)');
            parsedSuccessfully = true;

            // If text input is empty, use the file summary
            if (_cvController.text.isEmpty) {
              cvSummary = summary;
              debugPrint('CV PARSER: Using file summary as CV summary');
            }
            // If there's text input, combine with file summary
            else {
              cvSummary = "${_cvController.text}\n\nExtracted from CV: $summary";
              debugPrint('CV PARSER: Combining manual input with file summary');
            }
          } else {
            debugPrint('CV PARSER: Failed to extract summary from file content');
          }
        } else {
          debugPrint('CV PARSER: File content is null');
        }
      } catch (e) {
        debugPrint('CV PARSER ERROR: $e');
        // Show error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing CV: ${e.toString()}')),
          );
        }
      }
    }

    // Re-enable button
    if (mounted) {
      setState(() {
        _isInputValid = true;
      });
    }

    // Log final CV summary for verification
    debugPrint('FINAL CV SUMMARY: ${cvSummary?.length ?? 0} chars');
    if (cvSummary == null || cvSummary.isEmpty) {
      debugPrint('WARNING: CV summary is empty!');

      // Show warning to user if both text input and file parsing failed
      if (_filePath != null && !parsedSuccessfully) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not extract content from CV file. Proceeding without CV data.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    // Update the user profile with CV summary and language
    final updatedProfile = UserProfile(
      name: widget.userProfile.name,
      age: widget.userProfile.age,
      language: _language,
      cvSummary: cvSummary,
    );

    // Log the data being sent to interview screen
    debugPrint('SENDING TO INTERVIEW: Name: ${updatedProfile.name}, CV Summary Length: ${updatedProfile.cvSummary?.length ?? 0}');

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
            session: session
        ),
      ),
    );
  }
}
