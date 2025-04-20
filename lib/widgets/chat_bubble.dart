import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final bool isInterviewer;
  final String message;
  final bool isLoading;

  const ChatBubble({
    super.key,
    required this.isInterviewer,
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isInterviewer ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isInterviewer
              ? Colors.blue[100]
              : Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isInterviewer ? 'Interviewer' : 'You',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
      ),
    );
  }
}