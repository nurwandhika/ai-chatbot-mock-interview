import '../models/interview_result.dart';
import '../models/interview_session.dart';

class FeedbackController {
  // Process feedback from Gemini API
  InterviewResult processFeedback(InterviewSession session, Map<String, dynamic> feedbackData) {
    try {
      // Extract data from the feedback
      final int score = feedbackData['score'] ?? 0;

      List<String> strengths = [];
      if (feedbackData['strengths'] != null) {
        strengths = List<String>.from(feedbackData['strengths']);
      }

      List<String> improvements = [];
      if (feedbackData['improvements'] != null) {
        improvements = List<String>.from(feedbackData['improvements']);
      }

      final String feedback = feedbackData['feedback'] ?? 'No feedback available';

      // Create the interview result
      return InterviewResult(
        sessionId: session.userId,
        score: score,
        strengths: strengths,
        improvements: improvements,
        feedback: feedback,
      );
    } catch (e) {
      print('Error processing feedback: $e');

      // Return fallback data if there was an error
      return InterviewResult(
        sessionId: session.userId,
        score: 0,
        strengths: ['Could not process strengths'],
        improvements: ['Could not process improvements'],
        feedback: 'Error processing feedback: $e',
      );
    }
  }

  // Calculate score category based on score value
  String getScoreCategory(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    if (score >= 50) return 'Below Average';
    return 'Needs Improvement';
  }

  // Get color based on score
  int getScoreColor(int score) {
    if (score >= 80) return 0xFF4CAF50; // Green
    if (score >= 60) return 0xFFFFA726; // Orange
    return 0xFFE53935; // Red
  }
}