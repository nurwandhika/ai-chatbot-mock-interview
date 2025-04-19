import 'package:flutter/material.dart';
import '../utils/interview_roles.dart';
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
    String searchQuery = '';
    String selectedCategory = 'All';

    // Combine 'All' with other categories
    final Map<String, List<String>> categoriesMap = {
      'All': InterviewRoles.getAllRoles(),
      ...InterviewRoles.categories,
    };

    List<String> filteredRoles = [...categoriesMap['All']!];

    void filterRoles() {
      final categoryRoles = categoriesMap[selectedCategory] ?? [];
      if (searchQuery.isEmpty) {
        filteredRoles = categoryRoles;
      } else {
        filteredRoles = categoryRoles
            .where((role) => role.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          padding: EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Select your role',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search roles...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setStateModal(() {
                      searchQuery = value;
                      filterRoles();
                    });
                  },
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoriesMap.keys.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            setStateModal(() {
                              selectedCategory = category;
                              filterRoles();
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: filteredRoles.isEmpty
                    ? const Center(child: Text('No matching roles found'))
                    : ListView.builder(
                  itemCount: filteredRoles.length,
                  itemBuilder: (context, index) {
                    final role = filteredRoles[index];
                    return ListTile(
                      title: Text(role),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToInputInfo(context, InterviewType.technical, role);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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