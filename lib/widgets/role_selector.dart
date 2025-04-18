// lib/widgets/role_selector.dart
import 'package:flutter/material.dart';

class RoleSelector extends StatefulWidget {
  final Function(String) onRoleSelected;

  const RoleSelector({
    super.key,
    required this.onRoleSelected,
  });

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  final List<String> _roles = [
    'Software Engineer',
    'Mobile Developer',
    'Web Developer',
    'Data Scientist',
    'UI/UX Designer',
    'Product Manager',
    'QA Engineer',
    'DevOps Engineer',
    'Frontend Developer',
    'Backend Developer',
  ];

  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your job role',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _roles.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final role = _roles[index];
              return RadioListTile<String>(
                title: Text(role),
                value: role,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                  if (value != null) {
                    widget.onRoleSelected(value);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}