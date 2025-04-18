import 'package:flutter/material.dart';

class CvInputWidget extends StatefulWidget {
  final Function(String) onCvTextChanged;

  const CvInputWidget({
    super.key,
    required this.onCvTextChanged,
  });

  @override
  State<CvInputWidget> createState() => _CvInputWidgetState();
}

class _CvInputWidgetState extends State<CvInputWidget> {
  final TextEditingController _cvController = TextEditingController();

  @override
  void dispose() {
    _cvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CV or Experience Summary',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _cvController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Enter a summary of your experience...',
            border: OutlineInputBorder(),
          ),
          onChanged: widget.onCvTextChanged,
        ),
      ],
    );
  }
}