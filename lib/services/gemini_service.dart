import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/interview_session.dart';

class GeminiService {
  // Replace with your Gemini API key
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // Interview context
  Map<String, dynamic> _context = {};

  // Initialize with interview details
  void setupInterviewContext({
    required String userName,
    required int age,
    required InterviewType interviewType,
    String? role,
    String language = 'en',
    String? cvSummary,
  }) {
    _context = {
      'userName': userName,
      'age': age,
      'interviewType': interviewType == InterviewType.hr ? 'HR' : 'Technical',
      'role': role,
      'language': language,
      'cvSummary': cvSummary,
    };
  }

  // Generate initial prompt based on interview context
  String _generateInitialPrompt() {
    final langText = _context['language'] == 'id' ? 'Bahasa Indonesia' : 'English';

    if (_context['interviewType'] == 'HR') {
      return '''
Act as an HR interviewer conducting a mock interview in $langText. 
Your candidate is ${_context['userName']}, ${_context['age']} years old.
${_context['cvSummary'] != null ? 'Background info: ${_context['cvSummary']}' : ''}

Ask concise, professional HR interview questions one at a time. 
After 5-7 questions, end the interview and provide:
1. Score (1-100)
2. Strengths (2-3 bullet points)
3. Areas for improvement (2-3 bullet points)
4. Overall feedback (1-2 sentences)

Format the final evaluation as JSON: {"score": X, "strengths": ["point1", "point2"], "improvements": ["point1", "point2"], "feedback": "text"}
''';
    } else {
      return '''
Act as a technical interviewer for ${_context['role']} position, interviewing in $langText.
Your candidate is ${_context['userName']}, ${_context['age']} years old.
${_context['cvSummary'] != null ? 'Background info: ${_context['cvSummary']}' : ''}

Ask concise, relevant technical questions for ${_context['role']} one at a time.
After 5-7 questions, end the interview and provide:
1. Score (1-100)
2. Technical strengths (2-3 bullet points)
3. Areas for improvement (2-3 bullet points)
4. Overall feedback (1-2 sentences)

Format the final evaluation as JSON: {"score": X, "strengths": ["point1", "point2"], "improvements": ["point1", "point2"], "feedback": "text"}
''';
    }
  }

  // Start interview session by getting first question
  Future<String> startInterview() async {
    final prompt = _generateInitialPrompt();
    final response = await _sendPrompt(prompt);

    // Extract just the first question
    return _extractQuestion(response);
  }

  // Continue interview with user answer
  Future<Map<String, dynamic>> continueInterview(String userAnswer, List<QuestionAnswer> conversation) async {
    // Prepare conversation history for the prompt
    String conversationText = '';
    for (var qa in conversation) {
      conversationText += 'Interviewer: ${qa.question}\n';
      if (qa.answer != null) {
        conversationText += 'Candidate: ${qa.answer}\n';
      }
    }

    // Add the current answer
    conversationText += 'Candidate: $userAnswer\n';

    // Create follow-up prompt
    final followUpPrompt = '''
$conversationText

Continue the interview. If you've asked enough questions (5-7), provide the final assessment in JSON format.
If not, ask the next relevant question.
''';

    final response = await _sendPrompt(followUpPrompt);

    // Check if response contains JSON (interview ended)
    try {
      // Try to extract JSON
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        return {
          'isComplete': true,
          'feedback': json.decode(jsonString),
        };
      }
    } catch (e) {
      // Not JSON format, interview continues
    }

    // Return next question
    return {
      'isComplete': false,
      'nextQuestion': _extractQuestion(response),
    };
  }

  // Extract question from AI response
  String _extractQuestion(String response) {
    // Clean up response to extract just the question
    // Remove any AI role-playing text
    final cleanResponse = response
        .replaceAll(RegExp(r'^(As an (HR|interviewer|technical).*?\n)'), '')
        .trim();

    return cleanResponse;
  }

  // Send prompt to Gemini API
  Future<String> _sendPrompt(String prompt) async {
    try {
      final url = Uri.parse('$_apiUrl?key=$_apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Error: Could not generate response. Please try again.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Error: Could not connect to Gemini API. Please check your internet connection.';
    }
  }
}