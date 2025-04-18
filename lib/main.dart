import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'config/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MockInterviewApp());
}

class MockInterviewApp extends StatelessWidget {
  const MockInterviewApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'AI Mock Interview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
      home: const OnboardingScreen(),
      );
  }
}
