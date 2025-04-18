class UserProfile {
  final String name;
  final int age;
  final String language; // "en" for English, "id" for Bahasa Indonesia
  final String? cvSummary; // Text summary or path to CV file

  UserProfile({
    required this.name,
    required this.age,
    this.language = 'en',
    this.cvSummary,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'language': language,
    'cvSummary': cvSummary,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'],
    age: json['age'],
    language: json['language'] ?? 'en',
    cvSummary: json['cvSummary'],
  );
}