import 'dart:async';

import '../models/interview_session.dart';
import '../models/user_profile.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';

class InterviewController {
  final GeminiService _geminiService = GeminiService();

  // final SpeechService _speechService = SpeechService();

  InterviewSession? _currentSession;
  UserProfile? _userProfile;

  // Stream controllers for reactive UI updates
  final _questionStreamController = StreamController<String>.broadcast();
  final _loadingStreamController = StreamController<bool>.broadcast();
  final _completionStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<String> get questionStream => _questionStreamController.stream;

  Stream<bool> get loadingStream => _loadingStreamController.stream;

  Stream<Map<String, dynamic>> get completionStream =>
      _completionStreamController.stream;

  // Initialize the controller with user data
  Future<void> initialize(
    UserProfile userProfile,
    InterviewSession session,
  ) async {
    _currentSession = session;
    _userProfile = userProfile;

    // // Initialize speech service with user language
    // await _speechService.initialize();
    // _speechService.setLanguage(userProfile.language);

    // Initialize Gemini service with interview context
    _geminiService.setupInterviewContext(
      userName: userProfile.name,
      age: userProfile.age,
      interviewType: session.type,
      role: session.role,
      language: userProfile.language,
      cvSummary: userProfile.cvSummary,
    );

    // Start the interview
    await startInterview();
  }

  // Start the interview with first question
  Future<void> startInterview() async {
    _loadingStreamController.add(true);

    try {
      final question = await _geminiService.startInterview();

      if (_currentSession != null) {
        _currentSession!.addQuestion(question);
        _questionStreamController.add(question);
      }
    } catch (e) {
      _questionStreamController.add("Error starting interview: $e");
    } finally {
      _loadingStreamController.add(false);
    }
  }

  // Submit user's answer and get next question
  Future<void> submitAnswer(String answer) async {
    if (_currentSession == null) return;

    _loadingStreamController.add(true);
    _currentSession!.addAnswer(answer);

    try {
      final response = await _geminiService.continueInterview(
        answer,
        _currentSession!.conversation,
      );

      if (response['isComplete'] == true) {
        // Interview is complete, send feedback
        _currentSession!.completeSession();
        _completionStreamController.add(response['feedback']);
      } else {
        // Continue with next question
        final nextQuestion = response['nextQuestion'];
        _currentSession!.addQuestion(nextQuestion);
        _questionStreamController.add(nextQuestion);
      }
    } catch (e) {
      _questionStreamController.add("Error processing answer: $e");
    } finally {
      _loadingStreamController.add(false);
    }
  }

  // // Start speech recognition
  // Future<bool> startListening(Function(String) onResult) async {
  //   return _speechService.startListening(onResult);
  // }

  // // Stop speech recognition
  // Future<void> stopListening() async {
  //   await _speechService.stopListening();
  // }
  //
  // bool get isSpeechAvailable => _speechService.isAvailable;
  //
  // bool get isListening => _speechService.isListening;

  // Clean up resources
  void dispose() {
    _questionStreamController.close();
    _loadingStreamController.close();
    _completionStreamController.close();
  }
}
