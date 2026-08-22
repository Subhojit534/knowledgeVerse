import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/learning_models.dart';
import 'api_config.dart';
import 'api_service.dart';

/// Centralized service handling AI content fetching and ElevenLabs TTS integration.
class LearningService {
  LearningService._();

  static const Duration _timeout = Duration(seconds: 60);

  /// Cache for fetched learning content
  static final Map<String, LearningContentResponse> _cache = {};

  /// Fetches AI-generated learning explanation and 4 MCQs for a given subject building.
  static Future<LearningContentResponse> fetchLearningContent(LearningRequest request) async {
    final cacheKey = '${request.buildingId}_${request.subject}_${request.studentLevel}';
    if (_cache.containsKey(cacheKey)) {
      debugPrint('📦 [LearningService]: Returning cached content for $cacheKey');
      return _cache[cacheKey]!;
    }

    final base = ApiConfig.baseUrl;

    try {
      final response = await ApiService.post(
        '/api/learning/content',
        body: request.toJson(),
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final result = LearningContentResponse.fromJson(data, base);
        _cache[cacheKey] = result;
        return result;
      }
      debugPrint('❌ [LearningService]: Backend error ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [LearningService]: Exception fetching AI content: $e');
    }

    // Offline / fallback fallback path
    final fallback = _createOfflineContent(request);
    _cache[cacheKey] = fallback;
    return fallback;
  }

  /// Submits quiz completion results to the backend to update XP, Coins, Level, and Supabase progress.
  static Future<Map<String, dynamic>?> submitQuizResult({
    required String buildingId,
    required String subject,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    try {
      final response = await ApiService.post(
        '/api/learning/submit-quiz',
        body: {
          'building_id': buildingId,
          'subject': subject,
          'correct_answers': correctAnswers,
          'total_questions': totalQuestions,
        },
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        debugPrint('✅ [LearningService]: Quiz submitted successfully! XP Earned: ${data['xp_earned']}');
        return data;
      }
    } catch (e) {
      debugPrint('❌ [LearningService]: Exception submitting quiz result: $e');
    }
    return null;
  }

  /// Synthesizes speech for custom text (e.g., question reading, how-to-play tutorial).
  static Future<String?> fetchTTSAudioUrl(String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final response = await ApiService.post(
        '/api/tts',
        body: {'text': text},
        timeout: const Duration(seconds: 12),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final rawPath = data['audio_url'] as String?;
        if (rawPath != null && rawPath.isNotEmpty) {
          final base = ApiConfig.baseUrl;
          return rawPath.startsWith('http') ? rawPath : '$base$rawPath';
        }
      }
    } catch (e) {
      debugPrint('❌ [LearningService]: Exception fetching TTS audio: $e');
    }
    return null;
  }

  /// Generates offline default content if backend is completely offline.
  static LearningContentResponse _createOfflineContent(LearningRequest req) {
    final subj = req.subject.toLowerCase();
    String topic = 'Core Principles of ${req.subject}';
    String explanation =
        'Mastery requires understanding core principles. Break down complex ideas into manageable parts, use practical real-world analogies, and verify your knowledge through active practice.';

    List<MCQuestion> questions = [];

    if (subj.contains('code') || subj.contains('program')) {
      topic = 'Algorithms & Problem Solving';
      explanation =
          'An algorithm is a step-by-step procedure to solve a problem. Like a recipe, steps run sequentially. Variables hold data values, conditionals make decisions, and loops automate repetitive tasks efficiently.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'What is the main function of a loop in programming?',
          options: ['Store single value', 'Repeat code execution', 'Delete memory', 'Render UI style'],
          correctIndex: 1,
          explanation: 'Loops allow instructions to repeat without duplicating code.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which statement enables decision making in code?',
          options: ['Variable', 'Function', 'If-Else Statement', 'Array'],
          correctIndex: 2,
          explanation: 'If-else statements test conditions to execute branching code.',
        ),
        MCQuestion(
          id: 3,
          question: 'What does a variable hold in memory?',
          options: ['Data values', 'Screen pixels', 'Network speed', 'User passwords'],
          correctIndex: 0,
          explanation: 'Variables store data values that can be referenced and updated.',
        ),
        MCQuestion(
          id: 4,
          question: 'What happens when a loop has no exit condition?',
          options: ['Stops immediately', 'Runs infinitely', 'Compiles fast', 'Becomes variable'],
          correctIndex: 1,
          explanation: 'Infinite loops run indefinitely without stopping.',
        ),
      ];
    } else {
      questions = [
        MCQuestion(
          id: 1,
          question: 'What is the best way to master ${req.subject}?',
          options: ['Rote memorization', 'Conceptual understanding & practice', 'Skipping basics', 'Random guessing'],
          correctIndex: 1,
          explanation: 'Active problem solving and concept mastery produce lasting understanding.',
        ),
        MCQuestion(
          id: 2,
          question: 'Why break topics into smaller components?',
          options: ['Simplifies understanding', 'Wastes study time', 'Makes memory hard', 'Disables logic'],
          correctIndex: 0,
          explanation: 'Deconstructing topics makes learning manageable and clear.',
        ),
        MCQuestion(
          id: 3,
          question: 'What solidifies learning in memory?',
          options: ['Passive reading', 'Active practice & answering questions', 'Ignoring errors', 'No sleep'],
          correctIndex: 1,
          explanation: 'Applying knowledge through quiz questions reinforces recall.',
        ),
        MCQuestion(
          id: 4,
          question: 'How should learning mistakes be viewed?',
          options: ['As failure', 'As valuable learning feedback', 'As irrelevant', 'As reason to quit'],
          correctIndex: 1,
          explanation: 'Mistakes pinpoint exact concepts to review and improve.',
        ),
      ];
    }

    return LearningContentResponse(
      buildingId: req.buildingId,
      buildingName: req.buildingName,
      subject: req.subject,
      topic: topic,
      explanation: explanation,
      questions: questions,
      explanationAudioUrl: null,
      audioAvailable: false,
      source: 'offline',
      cacheKey: 'offline_${req.buildingId}',
    );
  }
}
