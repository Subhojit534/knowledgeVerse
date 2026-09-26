import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/player_profile.dart';
import 'api_service.dart';

/// Central state manager & API orchestrator for the KnowledgeVerse AI Scholar Chatbot.
///
/// Features:
/// - Full conversational multi-turn history ("previous chat keep support")
/// - Local persistent caching via SharedPreferences
/// - Integration with Groq AI fast inference through backend `/api/learning/chat`
/// - Pedagogical student context injection (Grade, Curriculum, Attuned Topic)
/// - Graceful offline fallback with guidance
class ChatbotService extends ChangeNotifier {
  ChatbotService._();

  static final ChatbotService instance = ChatbotService._();

  static const String _kStorageKey = 'knowledgeverse_ai_chat_history';
  static const int _kMaxHistoryTurns = 24;

  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  bool _isInitialized = false;

  String? _currentSubject;
  String? _currentTopic;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isGenerating => _isGenerating;
  bool get isInitialized => _isInitialized;
  String? get currentSubject => _currentSubject;
  String? get currentTopic => _currentTopic;

  /// Sets current active subject or topic context for targeted tutor explanations
  void setContext({String? subject, String? topic}) {
    _currentSubject = subject;
    _currentTopic = topic;
    notifyListeners();
  }

  /// Initializes the service and restores previous chat history from persistent storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadHistory();
    _isInitialized = true;
  }

  /// Restores previous conversation history from SharedPreferences
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      _messages.clear();

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _messages.add(ChatMessage.fromJson(item));
          }
        }
      }

      // If history is empty, initialize with an welcoming Archmage greeting
      if (_messages.isEmpty) {
        _messages.add(_buildInitialWelcomeMessage());
      }
    } catch (e) {
      debugPrint('⚠️ [ChatbotService]: Error loading previous chat history: $e');
      if (_messages.isEmpty) {
        _messages.add(_buildInitialWelcomeMessage());
      }
    } finally {
      notifyListeners();
    }
  }

  /// Persists current conversation history to SharedPreferences
  Future<void> saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep only up to the last 50 messages to maintain clean performance
      final toSave = _messages.length > 50
          ? _messages.sublist(_messages.length - 50)
          : _messages;
      final encoded = jsonEncode(toSave.map((m) => m.toJson()).toList());
      await prefs.setString(_kStorageKey, encoded);
    } catch (e) {
      debugPrint('⚠️ [ChatbotService]: Error persisting chat history: $e');
    }
  }

  /// Clears conversation history from local state and SharedPreferences
  Future<void> clearHistory() async {
    _messages.clear();
    _messages.add(_buildInitialWelcomeMessage());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStorageKey);
    notifyListeners();
  }

  /// Sends a user question to the AI Tutor with full multi-turn conversational history
  Future<void> sendMessage(
    String userText, {
    PlayerProfile? profile,
  }) async {
    final query = userText.trim();
    if (query.isEmpty || _isGenerating) return;

    // 1. Add user message to transcript
    final userMsg = ChatMessage(
      id: 'msg_user_${DateTime.now().microsecondsSinceEpoch}',
      role: 'user',
      content: query,
      timestamp: DateTime.now(),
      topic: _currentTopic,
      subject: _currentSubject,
    );
    _messages.add(userMsg);
    _isGenerating = true;
    notifyListeners();
    await saveHistory();

    // 2. Format previous chat history for Groq multi-turn context
    final history = _messages
        .where((m) => !m.isError && (m.role == 'user' || m.role == 'assistant'))
        .take(_kMaxHistoryTurns)
        .map((m) => m.toApiMap())
        .toList();

    // 3. Assemble pedagogical student context
    final effectiveProfile = profile ?? PlayerProfile.current;
    final studentContext = <String, dynamic>{
      'grade': effectiveProfile?.grade.isNotEmpty == true
          ? effectiveProfile!.grade
          : 'Class 10',
      'curriculum': effectiveProfile?.curriculum.isNotEmpty == true
          ? effectiveProfile!.curriculum
          : 'CBSE',
      'subject': _currentSubject ??
          (effectiveProfile?.subjects.isNotEmpty == true
              ? effectiveProfile!.subjects.first
              : 'Mathematics'),
      if (_currentTopic != null) 'activeTopic': _currentTopic,
      if (effectiveProfile?.activeTopicName != null)
        'attunedChapter': effectiveProfile!.activeTopicName,
      if (effectiveProfile?.activeSubtopicName != null)
        'attunedSubtopic': effectiveProfile!.activeSubtopicName,
      if (effectiveProfile?.activeTopicId != null)
        'topicId': effectiveProfile!.activeTopicId,
    };

    // 4. Request Groq completion via backend /api/learning/chat
    try {
      final res = await ApiService.chatWithTutor(
        message: query,
        messages: history,
        studentContext: studentContext,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final replyText = data['response']?.toString() ?? 'I hear your inquiry, young scholar.';

        final aiMsg = ChatMessage(
          id: 'msg_ai_${DateTime.now().microsecondsSinceEpoch}',
          role: 'assistant',
          content: replyText,
          timestamp: DateTime.now(),
          topic: _currentTopic,
          subject: _currentSubject,
        );
        _messages.add(aiMsg);
      } else {
        // Fallback response with pedagogical support
        final errorText = _generateFallbackResponse(query, studentContext);
        final fallbackMsg = ChatMessage(
          id: 'msg_ai_fallback_${DateTime.now().microsecondsSinceEpoch}',
          role: 'assistant',
          content: errorText,
          timestamp: DateTime.now(),
          isError: false,
        );
        _messages.add(fallbackMsg);
      }
    } catch (e) {
      debugPrint('❌ [ChatbotService Error]: $e');
      final fallbackText = _generateFallbackResponse(query, studentContext);
      final fallbackMsg = ChatMessage(
        id: 'msg_ai_offline_${DateTime.now().microsecondsSinceEpoch}',
        role: 'assistant',
        content: fallbackText,
        timestamp: DateTime.now(),
        isError: false,
      );
      _messages.add(fallbackMsg);
    } finally {
      _isGenerating = false;
      await saveHistory();
      notifyListeners();
    }
  }

  ChatMessage _buildInitialWelcomeMessage() {
    return ChatMessage(
      id: 'msg_welcome_${DateTime.now().microsecondsSinceEpoch}',
      role: 'assistant',
      content: 'Greetings, young scholar! I am Archmage Aetherius, your AI Scholar Tutor.\n\n'
          'I remember our entire conversation journey. Ask me any question from your curriculum, request step-by-step problem explanations, or explore academic mysteries together. What knowledge do you seek today?',
      timestamp: DateTime.now(),
    );
  }

  String _generateFallbackResponse(String query, Map<String, dynamic> context) {
    final subject = context['subject'] ?? 'your subject';
    final grade = context['grade'] ?? 'Class 10';
    return 'Knowledge flows from steady inquiry! Regarding "$query" in $grade $subject:\n\n'
        '• Start by reviewing core definitions and fundamental laws.\n'
        '• Break the problem down into given values and target unknowns.\n'
        '• Try consulting your Codex Spell Book chapters or attuning specific subtopics on the World Map.\n\n'
        '*(The ethereal Groq conduit is momentarily quiet, but I remain here to guide your studies!)*';
  }
}
