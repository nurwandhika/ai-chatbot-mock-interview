class InterviewResult {
  final String sessionId;
  final int score; // 1-100
  final List<String> strengths;
  final List<String> improvements;
  final String feedback;

  InterviewResult({
    required this.sessionId,
    required this.score,
    required this.strengths,
    required this.improvements,
    required this.feedback,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'score': score,
    'strengths': strengths,
    'improvements': improvements,
    'feedback': feedback,
  };

  factory InterviewResult.fromJson(Map<String, dynamic> json) => InterviewResult(
    sessionId: json['sessionId'],
    score: json['score'],
    strengths: List<String>.from(json['strengths']),
    improvements: List<String>.from(json['improvements']),
    feedback: json['feedback'],
  );
}