// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
//
// class SpeechService {
//   final SpeechToText _speech = SpeechToText();
//   bool _isInitialized = false;
//   Function(String)? _onResultCallback;
//   String _localeId = 'en_US';
//
//   // Initialize speech service
//   Future<bool> initialize() async {
//     if (_isInitialized) return true;
//
//     _isInitialized = await _speech.initialize(
//       onError: (error) => print('Speech recognition error: $error'),
//       onStatus: (status) => print('Speech recognition status: $status'),
//     );
//
//     return _isInitialized;
//   }
//
//   // Set language
//   void setLanguage(String languageCode) {
//     if (languageCode == 'id') {
//       _localeId = 'id_ID';
//     } else {
//       _localeId = 'en_US';
//     }
//   }
//
//   // Start listening
//   Future<bool> startListening(Function(String) onResult) async {
//     if (!_isInitialized) {
//       final initialized = await initialize();
//       if (!initialized) return false;
//     }
//
//     _onResultCallback = onResult;
//
//     try {
//       await _speech.listen(
//         onResult: _processResult,
//         localeId: _localeId,
//         listenMode: ListenMode.confirmation,
//         pauseFor: const Duration(seconds: 5),
//       );
//       return true; // If listen completes without throwing an exception
//     } catch (e) {
//       print('Speech recognition error: $e');
//       return false; // Return false if an error occurs
//     }
//   }
//
//   // Stop listening
//   Future<void> stopListening() async {
//     await _speech.stop();
//   }
//
//   // Check if speech recognition is available
//   bool get isAvailable => _isInitialized;
//
//   // Check if currently listening
//   bool get isListening => _speech.isListening;
//
//   // Process speech result
//   void _processResult(SpeechRecognitionResult result) {
//     if (result.finalResult && _onResultCallback != null) {
//       _onResultCallback!(result.recognizedWords);
//     }
//   }
// }
