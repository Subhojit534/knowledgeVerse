import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowledgeverse/game/ui/dialogs/ai_chatbot_dialog.dart';
import 'package:knowledgeverse/models/chat_message.dart';
import 'package:knowledgeverse/models/player_profile.dart';
import 'package:knowledgeverse/services/api_config.dart';
import 'package:knowledgeverse/services/api_service.dart';
import 'package:knowledgeverse/services/chatbot_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
    ApiConfig.setBaseUrl('http://127.0.0.1:8000');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ChatbotService.instance.clearHistory();
  });

  group('ChatMessage Model Tests', () {
    test('serializes and deserializes correctly', () {
      final msg = ChatMessage(
        id: 'msg_001',
        role: 'user',
        content: 'Explain Newton’s second law with formulas.',
        timestamp: DateTime(2026, 9, 26, 12, 0),
        topic: 'Laws of Motion',
        subject: 'Physics',
      );

      final json = msg.toJson();
      expect(json['id'], equals('msg_001'));
      expect(json['role'], equals('user'));
      expect(json['content'], contains('Newton'));
      expect(json['topic'], equals('Laws of Motion'));
      expect(json['subject'], equals('Physics'));

      final parsed = ChatMessage.fromJson(json);
      expect(parsed.id, equals('msg_001'));
      expect(parsed.role, equals('user'));
      expect(parsed.content, equals(msg.content));
      expect(parsed.isUser, isTrue);
      expect(parsed.isAssistant, isFalse);
    });

    test('toApiMap formats role and content for Groq multi-turn chat', () {
      final userMsg = ChatMessage(
        id: '1',
        role: 'user',
        content: 'Solve x^2 - 4 = 0',
        timestamp: DateTime.now(),
      );
      final apiMap = userMsg.toApiMap();
      expect(apiMap, equals({
        'role': 'user',
        'content': 'Solve x^2 - 4 = 0',
      }));
    });
  });

  group('ChatbotService Persistence & History Tests', () {
    test('initializes with Archmage greeting and loads from SharedPreferences', () async {
      final service = ChatbotService.instance;
      await service.initialize();

      expect(service.messages.isNotEmpty, isTrue);
      expect(service.messages.first.role, equals('assistant'));
      expect(service.messages.first.content, contains('Archmage Aetherius'));
    });

    test('persists conversation history across loads', () async {
      final service = ChatbotService.instance;
      await service.initialize();

      // Add a custom user message and response
      final prefs = await SharedPreferences.getInstance();
      final customList = [
        ChatMessage(
          id: 'test_1',
          role: 'user',
          content: 'What is the Pythagorean theorem?',
          timestamp: DateTime.now(),
        ).toJson(),
        ChatMessage(
          id: 'test_2',
          role: 'assistant',
          content: 'In a right-angled triangle: a^2 + b^2 = c^2.',
          timestamp: DateTime.now(),
        ).toJson(),
      ];
      await prefs.setString('knowledgeverse_ai_chat_history', jsonEncode(customList));

      // Reload history
      await service.loadHistory();
      expect(service.messages.length, equals(2));
      expect(service.messages[0].content, contains('Pythagorean'));
      expect(service.messages[1].content, contains('a^2 + b^2 = c^2'));
    });

    test('clearHistory purges previous conversation and restores Archmage greeting', () async {
      final service = ChatbotService.instance;
      await service.initialize();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('knowledgeverse_ai_chat_history', jsonEncode([
        {'id': '1', 'role': 'user', 'content': 'Old question', 'timestamp': DateTime.now().toIso8601String()}
      ]));
      await service.loadHistory();
      expect(service.messages.length, equals(1));

      await service.clearHistory();
      expect(service.messages.length, equals(1));
      expect(service.messages.first.content, contains('Archmage Aetherius'));

      final stored = prefs.getString('knowledgeverse_ai_chat_history');
      expect(stored, isNull);
    });
  });

  group('Live Groq API & ApiService Chat Integration Tests', () {
    test('chatWithTutor communicates with backend Groq AI and retains previous context', () async {
      final res = await ApiService.chatWithTutor(
        message: 'What is 12 times 12? Answer in one sentence.',
        messages: [
          {'role': 'user', 'content': 'Hello tutor, I need quick math help.'},
          {'role': 'assistant', 'content': 'Greetings scholar! What can I calculate for you?'},
          {'role': 'user', 'content': 'What is 12 times 12? Answer in one sentence.'},
        ],
        studentContext: {
          'grade': 'Class 10',
          'curriculum': 'CBSE',
          'subject': 'Mathematics',
        },
      );

      expect(res.statusCode, equals(200));
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['response'], isNotNull);
      final responseText = data['response'].toString();
      expect(responseText, contains('144'));
    });
  });

  group('AiChatbotDialog Widget Tests', () {
    testWidgets('renders Archmage dialog, header, suggestion chips, and input field', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      PlayerProfile.current = const PlayerProfile(
        name: 'Astral Explorer',
        grade: 'Class 10',
        curriculum: 'CBSE',
        activeTopicName: 'Polynomials',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => AiChatbotDialog.show(ctx, subject: 'Mathematics', topic: 'Polynomials'),
                child: const Text('Open AI Chatbot'),
              ),
            ),
          ),
        ),
      );

      // Open Dialog
      await tester.tap(find.text('Open AI Chatbot'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify Header
      expect(find.text('ARCHMAGE AETHERIUS'), findsOneWidget);
      expect(find.text('GROQ AI'), findsOneWidget);
      expect(find.byKey(const Key('chatbot_clear_history_btn')), findsOneWidget);
      expect(find.byKey(const Key('chatbot_close_dialog_btn')), findsOneWidget);

      // Verify Study Context Banner
      expect(find.textContaining('Class 10 (CBSE) • Mathematics • Chapter: Polynomials'), findsOneWidget);

      // Verify Suggestion Chips
      expect(find.text('Explain this topic simply with an example'), findsOneWidget);

      // Verify Input Field & Send Button
      expect(find.byKey(const Key('chatbot_input_field')), findsOneWidget);
      expect(find.byKey(const Key('chatbot_send_btn')), findsOneWidget);

      // Close dialog
      await tester.tap(find.byKey(const Key('chatbot_close_dialog_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    });
  });
}
