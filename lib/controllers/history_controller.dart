// lib/controllers/history_controller.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interview_session.dart';
import '../models/interview_result.dart';

class HistoryController {
  static const String _sessionKey = 'interview_sessions';
  static const String _resultKey = 'interview_results';

  // Save a completed interview session
  Future<bool> saveSession(InterviewSession session, InterviewResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing sessions
      final List<String> sessions = prefs.getStringList(_sessionKey) ?? [];
      final List<String> results = prefs.getStringList(_resultKey) ?? [];

      // Add new session and result
      sessions.add(jsonEncode(session.toJson()));
      results.add(jsonEncode(result.toJson()));

      // Save back to storage
      await prefs.setStringList(_sessionKey, sessions);
      await prefs.setStringList(_resultKey, results);

      return true;
    } catch (e) {
      print('Error saving session: $e');
      return false;
    }
  }

  // Get all history with sessions and results
  Future<List<Map<String, dynamic>>> getAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<String> sessions = prefs.getStringList(_sessionKey) ?? [];
      final List<String> results = prefs.getStringList(_resultKey) ?? [];

      // Combine sessions and results
      final List<Map<String, dynamic>> history = [];

      for (int i = 0; i < sessions.length; i++) {
        final sessionData = jsonDecode(sessions[i]);

        // Add result data if available
        if (i < results.length) {
          final resultData = jsonDecode(results[i]);
          sessionData['score'] = resultData['score'];
          sessionData['feedback'] = resultData['feedback'];
        }

        history.add(sessionData);
      }

      // Sort by date (newest first)
      history.sort((a, b) {
        final DateTime dateA = DateTime.parse(a['startTime']);
        final DateTime dateB = DateTime.parse(b['startTime']);
        return dateB.compareTo(dateA);
      });

      return history;
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }

  // Get a specific session by index
  Future<Map<String, dynamic>?> getSessionDetail(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<String> sessions = prefs.getStringList(_sessionKey) ?? [];
      final List<String> results = prefs.getStringList(_resultKey) ?? [];

      if (index < 0 || index >= sessions.length) return null;

      final sessionData = jsonDecode(sessions[index]);

      // Add result data if available
      if (index < results.length) {
        final resultData = jsonDecode(results[index]);
        sessionData['result'] = resultData;
      }

      return sessionData;
    } catch (e) {
      print('Error getting session details: $e');
      return null;
    }
  }

  // Clear all history
  Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_resultKey);
      return true;
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }
}