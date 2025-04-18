import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CvParserService {
  // Parse text from a file path (could be a PDF or text file)
  Future<String?> parseFromFile(String filePath) async {
    try {
      final extension = path.extension(filePath).toLowerCase();

      if (extension == '.txt') {
        // Read text file
        final file = File(filePath);
        return await file.readAsString();
      }
      else if (extension == '.pdf') {
        // For PDF, we'd ideally use a PDF parsing library
        // For MVP, return a placeholder message
        return "PDF parsing feature coming soon. Summary should be manually entered.";
      }
      else {
        return "Unsupported file format. Please use .txt or .pdf files.";
      }
    } catch (e) {
      print('CV parsing error: $e');
      return null;
    }
  }

  // Extract key information or summary from CV text
  Future<String?> extractSummary(String cvText) async {
    try {
      // For MVP, we'll use a simplified approach without real NLP
      // In a full implementation, this could use an AI service or NLP library

      // Simple keyword extraction
      final keywords = [
        'experience', 'skills', 'education', 'project',
        'work', 'achievement', 'language', 'certification'
      ];

      final paragraphs = cvText.split('\n\n');
      String summary = '';

      // Extract paragraphs that contain keywords
      for (final para in paragraphs) {
        for (final keyword in keywords) {
          if (para.toLowerCase().contains(keyword)) {
            summary += para + '\n\n';
            break;
          }
        }
      }

      // If summary is too long, truncate it
      if (summary.length > 500) {
        summary = summary.substring(0, 500) + '...';
      }

      return summary.isEmpty ? cvText.substring(0, min(cvText.length, 500)) : summary;
    } catch (e) {
      print('Summary extraction error: $e');
      return cvText;
    }
  }

  // Helper function to get min value
  int min(int a, int b) => a < b ? a : b;
}