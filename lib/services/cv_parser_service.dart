import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CvParserService {
  // Get API key for Gemini
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // Parse from file path
  Future<String?> parseFromFile(String filePath) async {
    try {
      debugPrint('CV PARSER: Starting to parse file: ${path.basename(filePath)}');
      debugPrint('CV PARSER: Parsing file from path: $filePath');
      final extension = path.extension(filePath).toLowerCase();
      debugPrint('CV PARSER: File extension: $extension');

      if (extension == '.txt') {
        // Read text file
        final file = File(filePath);
        if (await file.exists()) {
          final content = await file.readAsString();
          debugPrint('CV PARSER: Successfully read text file (${content.length} chars)');
          return content;
        } else {
          debugPrint('CV PARSER: File does not exist at path: $filePath');
          return null;
        }
      }
      else if (extension == '.pdf') {
        debugPrint('CV PARSER: Processing PDF using Syncfusion');
        // Extract text from PDF using Syncfusion
        final extractedText = await _extractTextFromPdf(filePath);
        if (extractedText != null && extractedText.isNotEmpty) {
          debugPrint('CV PARSER: Successfully extracted text from PDF (${extractedText.length} chars)');

          // Use Gemini to summarize the extracted text
          final summary = await _summarizeWithGemini(extractedText);
          if (summary != null) {
            debugPrint('CV PARSER: Generated summary using Gemini (${summary.length} chars)');
            return summary;
          }
          return extractedText;
        }
        return "Could not extract text from PDF.";
      }
      else {
        debugPrint('CV PARSER: Unsupported file format: $extension');
        return "Unsupported file format. Please use .txt or .pdf files.";
      }
    } catch (e) {
      debugPrint('CV PARSER ERROR: $e');
      return null;
    }
  }

  // Extract text from PDF using Syncfusion PDF library
  Future<String?> _extractTextFromPdf(String pdfPath) async {
    try {
      // Read the file
      final File file = File(pdfPath);
      final Uint8List bytes = await file.readAsBytes();

      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Extract text from the document
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();

      // Dispose the document
      document.dispose();

      debugPrint('PDF TEXT EXTRACTED: ${text.length} chars');
      return text;
    } catch (e) {
      debugPrint('PDF EXTRACTION ERROR: $e');
      return null;
    }
  }

  // Summarize extracted text using Gemini API
  Future<String?> _summarizeWithGemini(String extractedText) async {
    try {
      // Limit text size to avoid token limits
      final String limitedText = extractedText.length > 5000
          ? extractedText.substring(0, 5000)
          : extractedText;

      debugPrint('CV PARSER: Summarizing extracted text with Gemini');

      final prompt = '''
I'm processing a resume or CV. Here's the extracted text:

"""
$limitedText
"""

Create a concise but professional summary (300-500 words) of this candidate's:
- Professional experience
- Education
- Skills and competencies
- Notable achievements or projects

Format your response as clean text without headings or bullet points.
''';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$_apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 800},
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final summary = data['candidates'][0]['content']['parts'][0]['text'];
        return summary;
      } else {
        debugPrint('CV PARSER: API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('CV PARSER: Summarization error: $e');
      return null;
    }
  }

  // Parse from PlatformFile for web compatibility
  Future<String?> parseFromPlatformFile(PlatformFile file) async {
    try {
      debugPrint('CV PARSER: Parsing PlatformFile: ${file.name} (size: ${file.size})');
      final extension = path.extension(file.name).toLowerCase();
      debugPrint('CV PARSER: File extension: $extension');

      // For web platform
      if (kIsWeb) {
        debugPrint('CV PARSER: Running in web environment');
        if (extension == '.txt') {
          if (file.bytes != null) {
            final content = String.fromCharCodes(file.bytes!);
            debugPrint('CV PARSER: Successfully parsed web text file (${content.length} chars)');
            return content;
          } else {
            debugPrint('CV PARSER: Web file bytes are null');
          }
        } else if (extension == '.pdf') {
          debugPrint('CV PARSER: Processing web PDF file');
          if (file.bytes != null) {
            try {
              // Load the PDF document from bytes
              final PdfDocument document = PdfDocument(inputBytes: file.bytes!);

              // Extract text from the document
              final PdfTextExtractor extractor = PdfTextExtractor(document);
              final String text = extractor.extractText();

              // Dispose the document
              document.dispose();

              debugPrint('CV PARSER: Successfully extracted text from web PDF (${text.length} chars)');

              // Summarize with Gemini
              final summary = await _summarizeWithGemini(text);
              if (summary != null) {
                return summary;
              }
              return text;
            } catch (e) {
              debugPrint('CV PARSER: Web PDF extraction error: $e');
              return "Error extracting text from PDF. Please try another file.";
            }
          } else {
            debugPrint('CV PARSER: Web PDF bytes are null');
          }
        }
      }
      // For mobile platform
      else {
        debugPrint('CV PARSER: Running in mobile environment');
        if (file.path != null) {
          return parseFromFile(file.path!);
        } else {
          debugPrint('CV PARSER: Mobile file path is null');
        }
      }

      debugPrint('CV PARSER: Could not read file content');
      return "Could not read file content.";
    } catch (e) {
      debugPrint('CV PARSER ERROR: $e');
      return null;
    }
  }

  // Extract summary from CV text
  Future<String?> extractSummary(String cvText) async {
    try {
      debugPrint('CV PARSER: Extracting summary from ${cvText.length} chars of text');

      // If text is short enough, use it directly
      if (cvText.length <= 500) {
        debugPrint('CV PARSER: Text is already concise, using as-is');
        return cvText;
      }

      // Check if this looks like a Gemini-generated summary
      if (cvText.length < 2000 && !cvText.contains("PDF parsing feature coming soon")) {
        debugPrint('CV PARSER: Text appears to be a summary already, using as-is');
        return cvText;
      }

      // Simple keyword extraction
      final keywords = [
        'experience', 'skills', 'education', 'project',
        'work', 'achievement', 'language', 'certification'
      ];

      final paragraphs = cvText.split('\n\n');
      debugPrint('CV PARSER: Split into ${paragraphs.length} paragraphs');

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
        debugPrint('CV PARSER: Summary too long (${summary.length} chars), truncating to 500');
        summary = summary.substring(0, 500) + '...';
      }

      // If no keywords found, use the beginning of the CV
      if (summary.isEmpty) {
        debugPrint('CV PARSER: No keywords found, using first part of CV');
        summary = cvText.substring(0, min(cvText.length, 500));
        if (cvText.length > 500) {
          summary += '...';
        }
      }

      debugPrint('CV PARSER: Extracted summary (${summary.length} chars)');
      return summary;
    } catch (e) {
      debugPrint('CV PARSER: Summary extraction error: $e');
      // Return a portion of the original text as fallback
      if (cvText.length > 500) {
        return cvText.substring(0, 500) + '...';
      }
      return cvText;
    }
  }
}