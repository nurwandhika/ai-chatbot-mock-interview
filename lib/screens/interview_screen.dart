import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/interview_session.dart';
import 'feedback_screen.dart';
import '../services/gemini_service.dart';

class InterviewScreen extends StatefulWidget {
  final UserProfile userProfile;
  final InterviewSession session;

  const InterviewScreen({
    super.key,
    required this.userProfile,
    required this.session,
  });

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _textController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = true;
  bool _isSendingAnswer = false;
  bool _isComplete = false;
  int _questionCount = 0;

  @override
  void initState() {
    super.initState();
    _setupInterview();
  }

  Future<void> _setupInterview() async {
    // Initialize the Gemini service
    _geminiService.setupInterviewContext(
      userName: widget.userProfile.name,
      age: widget.userProfile.age,
      interviewType: widget.session.type,
      role: widget.session.role,
      language: widget.userProfile.language ?? 'en',
      cvSummary: widget.userProfile.cvSummary,
    );

    // Get first question
    final firstQuestion = await _geminiService.startInterview();
    _questionCount++;

    setState(() {
      widget.session.addQuestion(firstQuestion);
      _isLoading = false;
    });
  }

  Future<void> _sendAnswer(String answer) async {
    setState(() {
      _isSendingAnswer = true;
    });

    widget.session.addAnswer(answer);
    _textController.clear();

    // Get next question or feedback from Gemini
    final result = await _geminiService.continueInterview(
      answer,
      widget.session.conversation,
    );

    if (result['isComplete'] == true || _questionCount >= 10) {
      // Interview is complete
      widget.session.completeSession();
      setState(() {
        _isComplete = true;
        _isSendingAnswer = false;
      });

      // Show completion dialog
      _showCompletionDialog(result['feedback'] ?? {
        'score': 75,
        'strengths': ['Good communication', 'Technical knowledge'],
        'improvements': ['Be more concise', 'Provide more examples'],
        'feedback': 'Overall good interview performance with areas to improve.'
      });
    } else {
      // Add next question
      _questionCount++;
      widget.session.addQuestion(result['nextQuestion']);
      setState(() {
        _isSendingAnswer = false;
      });
    }
  }

  void _showCompletionDialog(Map<String, dynamic> feedback) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: const Text('Interview Complete'),
            content: const Text(
              'You have completed the interview session. Would you like to see your feedback?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToFeedback(feedback);
                },
                child: const Text('View Feedback'),
              ),
            ],
          ),
    );
  }

  void _navigateToFeedback(Map<String, dynamic> feedback) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FeedbackScreen(
              session: widget.session,
              result: feedback,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Session'),
        actions: [
          TextButton(
            onPressed: _isComplete ? null : () {
              widget.session.completeSession();
              _showEndInterviewDialog();
            },
            child: const Text('End Interview'),
            style: TextButton.styleFrom(
              foregroundColor: _isComplete ? Colors.grey : Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Interview info
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[200],
            child: Row(
              children: [
                Icon(
                  widget.session.type == InterviewType.hr
                      ? Icons.person_outline
                      : Icons.code,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.session.type == InterviewType.hr
                      ? 'HR Interview'
                      : 'Technical Interview: ${widget.session.role}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Chat area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.session.conversation.length,
              itemBuilder: (context, index) {
                final qa = widget.session.conversation[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Interviewer: ${qa.question}'),
                    ),
                    // Answer if exists
                    if (qa.answer != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(
                          left: 24,
                          bottom: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('You: ${qa.answer}'),
                      ),
                  ],
                );
              },
            ),
          ),

          // Input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your answer...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    enabled: !_isComplete,
                  ),
                ),
                IconButton(
                  icon: _isSendingAnswer
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.send),
                  onPressed: (_isSendingAnswer || _isComplete)
                      ? null
                      : () {
                    if (_textController.text
                        .trim()
                        .isNotEmpty) {
                      _sendAnswer(_textController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEndInterviewDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('End Interview'),
            content: const Text(
              'Are you sure you want to end this interview? This will generate feedback based on your answers so far.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _endInterviewEarly();
                },
                child: const Text('End Interview'),
              ),
            ],
          ),
    );
  }

  Future<void> _endInterviewEarly() async {
    setState(() {
      _isLoading = true;
    });

    // Generate a final feedback based on the answers so far
    final lastAnswer = widget.session.conversation.isNotEmpty &&
        widget.session.conversation.last.answer != null ?
    widget.session.conversation.last.answer! : "No answer";

    final result = await _geminiService.continueInterview(
      lastAnswer + "\n[END_INTERVIEW]", // Signal to end interview
      widget.session.conversation,
    );

    setState(() {
      _isComplete = true;
      _isLoading = false;
    });

    // Navigate to feedback
    _navigateToFeedback(result['feedback'] ?? {
      'score': 70,
      'strengths': ['Good effort', 'Participated in interview'],
      'improvements': ['Complete the full interview next time'],
      'feedback': 'Interview ended early. Feedback based on partial responses.'
    });
  }
}