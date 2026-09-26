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

    test('saveUserProfile saves profile to database and retrieves it', () async {
      final testProfile = {
        'name': 'Test Explorer Integration',
        'difficulty': 'Medium',
        'grade': 'Class 10',
        'curriculum': 'CBSE',
        'avatar_id': '0',
        'xp': 200,
        'level': 1,
        'coins': 550,
      };
      final res = await ApiService.saveUserProfile(testProfile);
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['profile'], isNotNull);
      final profileId = data['profile']['id'] as String;

      final fetchRes = await ApiService.getProfileById(profileId);
      expect(fetchRes.statusCode, equals(200));
      final fetchData = jsonDecode(utf8.decode(fetchRes.bodyBytes)) as Map<String, dynamic>;
      expect(fetchData['success'], isTrue);
      expect(fetchData['profile']['id'], equals(profileId));
    });

    test('submitQuizScore updates student progress and awards rewards', () async {
      final res = await ApiService.submitQuizScore({
        'user_id': '15c6df36-622e-4597-bc38-46f96e83f715',
        'building_id': 'code',
        'subject': 'Computer Science',
        'correct_answers': 4,
        'total_questions': 4,
        'difficulty': 'Medium',
      });
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['xp_earned'], isNotNull);
      expect(data['coins_earned'], isNotNull);
    });

    test('getMyGuild and guild messaging interact with DB', () async {
      final res = await ApiService.getMyGuild('15c6df36-622e-4597-bc38-46f96e83f715');
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);

      if (data['guild'] != null) {
        final guildId = data['guild']['id'] as String;
        final msgRes = await ApiService.sendGuildMessage(
          guildId: guildId,
          senderId: '15c6df36-622e-4597-bc38-46f96e83f715',
          text: 'Integration test message',
        );
        expect(msgRes.statusCode, equals(200));

        final listRes = await ApiService.getGuildMessages(guildId);
        expect(listRes.statusCode, equals(200));
        final listData = jsonDecode(utf8.decode(listRes.bodyBytes)) as Map<String, dynamic>;
        expect(listData['success'], isTrue);
      }
    });

    test('getInventory fetches player bag and equipment', () async {
      final res = await ApiService.getInventory('15c6df36-622e-4597-bc38-46f96e83f715');
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['inventory'], isA<List>());
      expect(data['equipped'], isNotNull);
    });

    test('getPvPStats fetches duelist combat records', () async {
      final res = await ApiService.getPvPStats('15c6df36-622e-4597-bc38-46f96e83f715');
      expect(res.statusCode, equals(200));

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      expect(data['success'], isTrue);
      expect(data['stats'], isNotNull);
    });
  });
}
