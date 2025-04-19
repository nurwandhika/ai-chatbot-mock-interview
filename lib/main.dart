import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'config/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Add this line to ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
    // Fallback option if needed
  }

  runApp(const MockInterviewApp());
}

class MockInterviewApp extends StatelessWidget {
  const MockInterviewApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'AI Mock Interview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}