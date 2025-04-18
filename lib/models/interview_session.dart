enum InterviewType { hr, technical }

class InterviewSession {
  final String userId;
  final InterviewType type;
  final String? role; // Only applicable for technical interviews
  final List<QuestionAnswer> conversation;
  final DateTime startTime;
  DateTime? endTime;

  InterviewSession({
    required this.userId,
    required this.type,
    this.role,
    required this.startTime,
    List<QuestionAnswer>? conversation,
  }) : conversation = conversation ?? [];

  bool get isCompleted => endTime != null;

  void addQuestion(String question) {
    conversation.add(QuestionAnswer(question: question));
  }

  void addAnswer(String answer) {
    if (conversation.isNotEmpty && conversation.last.answer == null) {
      conversation.last.answer = answer;
    }
  }

  void completeSession() {
    endTime = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'type': type.toString(),
    'role': role,
    'conversation': conversation.map((qa) => qa.toJson()).toList(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
  };

  factory InterviewSession.fromJson(Map<String, dynamic> json) => InterviewSession(
    userId: json['userId'],
    type: json['type'] == 'InterviewType.hr' ? InterviewType.hr : InterviewType.technical,
    role: json['role'],
    startTime: DateTime.parse(json['startTime']),
  )
    ..conversation.addAll((json['conversation'] as List)
        .map((qa) => QuestionAnswer.fromJson(qa)))
    ..endTime = json['endTime'] != null ? DateTime.parse(json['endTime']) : null;
}

class QuestionAnswer {
  final String question;
  String? answer;

  QuestionAnswer({required this.question, this.answer});

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
  };

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) => QuestionAnswer(
    question: json['question'],
    answer: json['answer'],
  );
}