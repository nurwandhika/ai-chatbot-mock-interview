import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For demo, use mock data
    // In production, load from storage (Hive or SharedPreferences)
    final mockSessions = [
      {
        'userId': 'John Doe',
        'type': 'InterviewType.hr',
        'role': null,
        'startTime':
            DateTime.now().subtract(const Duration(days: 2)).toString(),
        'endTime': DateTime.now().subtract(const Duration(days: 2)).toString(),
        'score': 85,
      },
      {
        'userId': 'John Doe',
        'type': 'InterviewType.technical',
        'role': 'Software Engineer',
        'startTime':
            DateTime.now().subtract(const Duration(days: 1)).toString(),
        'endTime': DateTime.now().subtract(const Duration(days: 1)).toString(),
        'score': 72,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Interview History')),
      body:
          mockSessions.isEmpty
              ? const Center(child: Text('No interview history yet.'))
              : ListView.builder(
                itemCount: mockSessions.length,
                itemBuilder: (context, index) {
                  final session = mockSessions[index];
                  final isHr = session['type'] == 'InterviewType.hr';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Icon(
                        isHr ? Icons.person_outline : Icons.code,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        isHr ? 'HR Interview' : 'Technical: ${session['role']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Date: ${DateTime.parse(session['startTime'] as String).toString().split('.')[0]}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(session['score'] as int),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${session['score']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        // View session details (not implemented in this minimal version)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Session details view not implemented yet',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
