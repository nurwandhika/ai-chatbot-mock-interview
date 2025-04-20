import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/interview_session.dart';

class GeminiService {
  // Replace with your Gemini API key
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';

  // Interview context
  Map<String, dynamic> _context = {};
  bool _isFirstQuestion = true;

  // List of common interviewer names
  static const List<String> _hrInterviewerNames = [
    'Sarah',
    'Michael',
    'Lisa',
    'David',
    'Sophia',
    'James',
    'Emma',
    'John',
    'Olivia',
    'Robert',
    'Maya',
    'Daniel',
    'Rina',
    'Alex',
    'Maria',
  ];

  static const List<String> _technicalInterviewerNames = [
    'Ryan',
    'Rachel',
    'Sam',
    'Nina',
    'Dev',
    'Thomas',
    'Priya',
    'Kevin',
    'Lena',
    'Brian',
    'Jane',
    'Mark',
    'Sasha',
    'Eric',
    'Diana',
  ];

  // The Interviewer's name
  late String _interviewerName;

  // Initialize with interview details
  void setupInterviewContext({
    required String userName,
    required int age,
    required InterviewType interviewType,
    String? role,
    String language = 'en',
    String? cvSummary,
  }) {
    // Select an appropriate interviewer name based on interview type
    final namesList =
        (interviewType == InterviewType.hr)
            ? _hrInterviewerNames
            : _technicalInterviewerNames;

    _interviewerName = namesList[Random().nextInt(namesList.length)];

    _context = {
      'userName': userName,
      'age': age,
      'interviewType': interviewType == InterviewType.hr ? 'HR' : 'Technical',
      'role': role,
      'language': language,
      'cvSummary': cvSummary,
      'interviewerName': _interviewerName,
    };
    _isFirstQuestion = true;

    // In GeminiService class, setupInterviewContext method
    debugPrint(
      'CV SUMMARY RECEIVED: ${cvSummary?.substring(0, min(50, cvSummary?.length ?? 0))}... (${cvSummary?.length ?? 0} chars)',
    );

    // Log the setup information
    debugPrint('Interview Setup: ${json.encode(_context)}');
    debugPrint('Interviewer Name: $_interviewerName');
  }

  // Start interview session by getting first question from AI
  Future<String> startInterview() async {
    final langText =
        _context['language'] == 'id' ? 'Bahasa Indonesia' : 'English';
    final cvInfo =
        _context['cvSummary'] != null
            ? 'CV/Background info: ${_context['cvSummary']}'
            : '';

    final prompt = '''
You are a professional ${_context['interviewType']} interviewer conducting an interview in $langText.
IMPORTANT: Your name is ${_context['interviewerName']}. You must introduce yourself as ${_context['interviewerName']} and never as "[Your Name]" or any placeholder.
Your candidate is ${_context['userName']}, ${_context['age']} years old.
${_context['interviewType'] == 'Technical' ? 'The position is for ${_context['role']}.' : ''}
$cvInfo

Start the interview with a professional greeting that includes your name ${_context['interviewerName']} explicitly, and ask the first interview question.
The first question should ask the candidate to introduce themselves and their background.
Be natural and professional like in a real interview.
Ask only one question.

REMEMBER: Your name is ${_context['interviewerName']}. Do NOT use placeholders like [Your Name] or [Name].
''';

    // Log the initial prompt
    _logPrompt('INITIAL_PROMPT', prompt);

    final response = await _sendPrompt(prompt);
    _isFirstQuestion = false;

    // Log the response
    _logResponse('INITIAL_RESPONSE', response);

    return _extractQuestion(response);
  }

  // Continue interview with user answer
  Future<Map<String, dynamic>> continueInterview(
    String userAnswer,
    List<QuestionAnswer> conversation,
  ) async {
    final langText =
        _context['language'] == 'id' ? 'Bahasa Indonesia' : 'English';

    // Format conversation history
    String conversationText = _formatConversationHistory(conversation);

    // Add the current answer
    conversationText += 'Candidate: $userAnswer\n';

    bool forceEnd = userAnswer.contains("[END_INTERVIEW]");

    // Create follow-up prompt
    final followUpPrompt = '''
You are a professional ${_context['interviewType']} interviewer conducting an interview in $langText.
IMPORTANT: Your name is ${_context['interviewerName']}. Always use this exact name if you need to refer to yourself.
${_context['interviewType'] == 'Technical' ? 'The position is for ${_context['role']}.' : ''}
${_context['cvSummary'] != null ? 'CV/Background info: ${_context['cvSummary']}' : ''}

This is the conversation so far:
$conversationText

${forceEnd ? 'The interview needs to end now. Provide a final assessment in JSON format.' : 'Continue the interview. Ask a professional, relevant question based on the candidate\'s answers and CV.'}
Don't repeat questions that have already been asked.
${forceEnd || conversation.length >= 18 ? 'Provide the final assessment in JSON format.' : 'If you\'ve asked a total of 10 questions or covered all relevant areas, provide the final assessment in JSON format.'}
The final assessment should be in this exact format: {"score": X, "strengths": ["point1", "point2"], "improvements": ["point1", "point2"], "feedback": "text"}

REMEMBER: Your name is ${_context['interviewerName']}. Never use placeholders like [Your Name].
''';

    // Log the follow-up prompt
    _logPrompt('FOLLOW_UP_PROMPT', followUpPrompt);

    final response = await _sendPrompt(followUpPrompt);

    // Log the response
    _logResponse('FOLLOW_UP_RESPONSE', response);

    // Check if response contains JSON (interview ended)
    try {
      // Try to extract JSON
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        debugPrint('INTERVIEW_COMPLETE: Found JSON feedback');
        return {'isComplete': true, 'feedback': json.decode(jsonString)};
      }
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
      // Not JSON format, interview continues
    }

    // Return next question
    return {'isComplete': false, 'nextQuestion': _extractQuestion(response)};
  }

  // Format conversation history for the AI
  String _formatConversationHistory(List<QuestionAnswer> conversation) {
    String history = '';
    for (var qa in conversation) {
      history += 'Interviewer: ${qa.question}\n';
      if (qa.answer != null) {
        history += 'Candidate: ${qa.answer}\n';
      }
    }
    return history;
  }

  // Extract question from AI response
  String _extractQuestion(String response) {
    // Clean up response to extract just the question
    final cleanResponse =
        response
            .replaceAll(RegExp(r'Interviewer:|Candidate:'), '')
            .replaceAll(RegExp(r'\n+'), '\n')
            .trim();

    return cleanResponse;
  }

  // Log prompt to console for debugging
  void _logPrompt(String label, String prompt) {
    debugPrint('===================== $label =====================');
    debugPrint(prompt);
    debugPrint('===================== END $label =====================');
  }

  // Log API response to console
  void _logResponse(String label, String response) {
    debugPrint('===================== $label =====================');
    // Truncate long responses for clarity
    if (response.length > 500) {
      debugPrint('${response.substring(0, 500)}... (truncated)');
    } else {
      debugPrint(response);
    }
    debugPrint('===================== END $label =====================');
  }

  // Send prompt to Gemini API
  Future<String> _sendPrompt(String prompt) async {
    try {
      final url = Uri.parse('$_apiUrl?key=$_apiKey');
      debugPrint('Sending request to: ${url.toString().split('?').first}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        debugPrint('API Error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');

        if (response.statusCode == 404) {
          return _sendPromptWithFallbackModel(prompt);
        }

        return 'Error: Could not generate response. Please try again.';
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return 'Error: Could not connect to Gemini API. Please check your internet connection.';
    }
  }

  // Fallback to another model if main model fails
  Future<String> _sendPromptWithFallbackModel(String prompt) async {
    try {
      // Try with gemini-1.5-pro
      final fallbackUrl = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$_apiKey',
      );

      debugPrint(
        'Trying fallback model at: ${fallbackUrl.toString().split('?').first}',
      );

      final response = await http.post(
        fallbackUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        debugPrint('Fallback API Error: ${response.statusCode}');
        debugPrint('Fallback Response: ${response.body}');
        return 'Error: Could not generate response. Please check your API key and billing setup.';
      }
    } catch (e) {
      debugPrint('Fallback Exception: $e');
      return 'Error: Could not connect to Gemini API. Please check your internet connection.';
    }
  }
}
