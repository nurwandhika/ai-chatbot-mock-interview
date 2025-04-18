import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/interview_session.dart';
import '../models/user_profile.dart';
import 'input_info_screen.dart';

class InterviewTypeScreen extends StatelessWidget {
  final String name;
  final int age;

  const InterviewTypeScreen({
    super.key,
    required this.name,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Interview Type')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hello, $name!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 30),
            const Text('What type of interview would you like to practice?'),
            const SizedBox(height: 20),
            _buildTypeButton(
              context,
              AppStrings.hrInterview,
              'General questions about personality, motivation, and soft skills',
              null, // HR interview doesn't need a specific role
            ),
            const SizedBox(height: 16),
            _buildTypeButton(
              context,
              AppStrings.userInterview,
              'Technical questions specific to your job role',
              _showRoleSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(
      BuildContext context,
      String title,
      String description,
      Function(BuildContext)? onPressed,
      ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        alignment: Alignment.centerLeft,
      ),
      onPressed: () {
        if (onPressed != null) {
          onPressed(context);
        } else {
          _navigateToInputInfo(context, InterviewType.hr, null);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showRoleSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your role', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...InterviewRoles.getAllRoles().map((role) => ListTile(
              title: Text(role),
              onTap: () {
                Navigator.pop(context);
                _navigateToInputInfo(context, InterviewType.technical, role);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _navigateToInputInfo(BuildContext context, InterviewType type, String? role) {
    final userProfile = UserProfile(name: name, age: age);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputInfoScreen(
          userProfile: userProfile,
          interviewType: type,
          role: role,
        ),
      ),
    );
  }
}