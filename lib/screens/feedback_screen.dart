import 'package:flutter/material.dart';
import '../models/interview_session.dart';
import '../models/interview_result.dart';
import 'history_screen.dart';

class FeedbackScreen extends StatelessWidget {
  final InterviewSession session;
  final Map<String, dynamic> result; // Placeholder for API result

  const FeedbackScreen({
    super.key,
    required this.session,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    // Create InterviewResult from the result map
    final interviewResult = InterviewResult(
      sessionId: session.userId,
      score: result['score'],
      strengths: List<String>.from(result['strengths']),
      improvements: List<String>.from(result['improvements']),
      feedback: result['feedback'],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Interview Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score display
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getScoreColor(interviewResult.score),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${interviewResult.score}',
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Score',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Feedback sections
            const Text('Strengths', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._buildBulletPoints(interviewResult.strengths),
            const SizedBox(height: 16),

            const Text('Areas for Improvement', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._buildBulletPoints(interviewResult.improvements),
            const SizedBox(height: 16),

            const Text('Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(interviewResult.feedback),

            const Spacer(),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Go back to home
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('New Interview'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // View history
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: const Text('View History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  List<Widget> _buildBulletPoints(List<String> points) {
    return points.map((point) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(point)),
        ],
      ),
    )).toList();
  }
}