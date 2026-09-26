import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledgeverse/services/api_config.dart';
import 'package:knowledgeverse/services/api_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _RealHttpOverrides();
    ApiConfig.setBaseUrl('http://127.0.0.1:8000');
  });

  group('ApiService Real Backend Integration & Route Tests', () {
    test('getClasses fetches classes from live backend successfully', () async {
      final res = await ApiService.getClasses(board: 'CBSE');
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['classes'], isA<List>());
      final list = data['classes'] as List;
      expect(list.length, greaterThanOrEqualTo(8));
    });

    test('getLeaderboard fetches global leaderboard', () async {
      final res = await ApiService.getLeaderboard('GLOBAL');
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['leaderboard'], isA<List>());
    });

    test('getShopItems fetches catalog', () async {
      final res = await ApiService.getShopItems('ALL');
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
    });

    test('getPublicGuilds fetches public guilds', () async {
      final res = await ApiService.getPublicGuilds();
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['guilds'], isA<List>());
    });

    test('getLearningContent fetches questions from AI / seed dataset', () async {
      final res = await ApiService.getLearningContent({
        'building_id': 'code',
        'building_name': 'Tower of Algorithms',
        'subject': 'Computer Science',
        'student_level': 1,
        'grade': 'Class 10',
        'curriculum': 'CBSE',
      });
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['building_id'], equals('code'));
      expect(data['questions'], isA<List>());
      final qList = data['questions'] as List;
      expect(qList.length, greaterThanOrEqualTo(4));
    });

    test('getPvPLeaderboard fetches duel leaderboard', () async {
      final res = await ApiService.getPvPLeaderboard();
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
    });
  });
}
