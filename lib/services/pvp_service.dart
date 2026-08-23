import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_models.dart';
import '../models/player_profile.dart';
import '../models/pvp_models.dart';
import 'api_service.dart';

/// Centralized client service for all PvP Duel Arena operations
class PvPService {
  PvPService._();

  static const Duration _timeout = Duration(seconds: 15);
  static String _cachedClientId = '';

  /// Public getter for the cached unique client ID
  static String get cachedClientId => _cachedClientId;

  /// Returns a persistent unique device/client identifier for this install
  static Future<String> getClientId() async {
    if (_cachedClientId.isNotEmpty) return _cachedClientId;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('device_unique_client_id')?.trim();
    if (id == null || id.isEmpty) {
      final randCode = math.Random().nextInt(90000) + 10000;
      id = 'duelist_${DateTime.now().millisecondsSinceEpoch % 1000000}_$randCode';
      await prefs.setString('device_unique_client_id', id);
    }
    _cachedClientId = id;
    return id;
  }


  /// Initiates matchmaking or instantly pairs with AI Scholar (Practice) or real humans (Duel)
  static Future<PvPSession?> matchmake({
    required String subject,
    int stakeCoins = 50,
    bool isRanked = true,
  }) async {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final clientId = await getClientId();
    final playerName = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'Duelist_${clientId.split('_').last}';

    try {
      final response = await ApiService.post(
        '/api/pvp/matchmake',
        body: {
          'userId': clientId,
          'playerName': playerName,
          'subject': subject,
          'stakeCoins': stakeCoins,
          'isRanked': isRanked,
          'grade': profile.grade.isNotEmpty ? profile.grade : 'Class 10',
          'curriculum': profile.curriculum.isNotEmpty ? profile.curriculum : 'CBSE',
        },
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (data['session'] != null) {
          return PvPSession.fromJson(data['session'] as Map<String, dynamic>);
        }
        if (data['waiting'] == true) {
          // Still waiting in queue for a real human duelist
          return null;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Matchmake Warning]: $e');
    }

    if (!isRanked) {
      // Offline / Local Practice with AI Bot
      return _createOfflineSession(subject, stakeCoins, false, profile);
    }
    return null;
  }

  /// Cancels active search in the real duelist matchmaking queue
  static Future<void> cancelMatchmaking() async {
    final clientId = await getClientId();
    try {
      await ApiService.post(
        '/api/pvp/matchmake/cancel',
        body: {'userId': clientId},
        timeout: const Duration(seconds: 4),
      );
    } catch (_) {}
  }

  /// Submits one round's answer and receives damage/score result and updated session
  static Future<PvPRoundResponse?> submitRound({
    required String sessionId,
    required String userId,
    required int roundIndex,
    required int selectedIndex,
    required int timeTakenMs,
  }) async {
    try {
      final response = await ApiService.post(
        '/api/pvp/session/$sessionId/round',
        body: {
          'user_id': userId,
          'round_index': roundIndex,
          'selected_index': selectedIndex,
          'time_taken_ms': timeTakenMs,
        },
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        PvPSession? session;
        PvPRoundResult? roundResult;

        if (data['session'] != null) {
          session = PvPSession.fromJson(data['session'] as Map<String, dynamic>);
        }
        if (data['roundResult'] != null) {
          roundResult = PvPRoundResult.fromJson(data['roundResult'] as Map<String, dynamic>);
        }

        return PvPRoundResponse(session: session, roundResult: roundResult);
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Submit Round Error]: $e');
    }
    return null;
  }


  /// Finalizes the duel match, calculates rewards and updates player economy
  static Future<Map<String, dynamic>?> finishSession(String sessionId) async {
    try {
      final response = await ApiService.post(
        '/api/pvp/session/$sessionId/finish',
        body: {},
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return data;
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Finish Session Error]: $e');
    }
    return null;
  }

  static PvPStats? _cachedUserStats;

  /// Fetches player's career PvP statistics & league tier
  static Future<PvPStats> getUserStats([String? customUserId]) async {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final userId = customUserId ?? (profile.id.isNotEmpty ? profile.id : (profile.name.isNotEmpty ? profile.name : 'demo-user-123'));

    if (customUserId == null && _cachedUserStats != null) {
      return _cachedUserStats!;
    }

    try {
      final response = await ApiService.get(
        '/api/pvp/stats/$userId',
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (data['stats'] != null) {
          final s = PvPStats.fromJson(data['stats'] as Map<String, dynamic>);
          if (customUserId == null) _cachedUserStats = s;
          return s;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Get Stats Warning]: $e');
    }

    // Default initial starting stats (Level 1 base: 1165 MMR)
    final defaultStats = PvPStats(
      userId: userId,
      name: profile.name.isNotEmpty ? profile.name : 'Scholar Duelist',
      rating: 1165,
      tier: PvPTier.silver,
      wins: 0,
      losses: 0,
      draws: 0,
      totalMatches: 0,
      winRate: 0.0,
      currentStreak: 0,
      bestStreak: 0,
      totalCoinsWon: 0,
      favoriteSubject: profile.subjects.isNotEmpty ? profile.subjects.first : 'Mathematics',
    );
    if (customUserId == null) _cachedUserStats ??= defaultStats;
    return _cachedUserStats ?? defaultStats;
  }

  /// Real-time Match Result Recording (Coins, XP, MMR & Streak)
  static Future<PvPStats> recordMatchResult({
    required bool isWinner,
    required bool isDraw,
    required int stakeCoins,
    required int ratingDelta,
    required int coinsDelta,
    required int xpEarned,
    required String subject,
  }) async {
    final profile = PlayerProfile.current ?? const PlayerProfile();

    // 1. Update Player Economy (Coins & XP) in real time
    final updatedCoins = math.max(0, profile.coins + coinsDelta);
    final updatedXp = profile.xp + xpEarned;
    final updatedProfile = profile.copyWith(coins: updatedCoins, xp: updatedXp);
    await updatedProfile.save();

    // 2. Update Career PvP Stats in real time
    final current = _cachedUserStats ?? await getUserStats();
    final newWins = isWinner ? current.wins + 1 : current.wins;
    final newLosses = (!isWinner && !isDraw) ? current.losses + 1 : current.losses;
    final newDraws = isDraw ? current.draws + 1 : current.draws;
    final total = newWins + newLosses + newDraws;
    final newRating = math.max(1000, current.rating + ratingDelta);
    final newStreak = isWinner ? current.currentStreak + 1 : 0;
    final newBestStreak = math.max(current.bestStreak, newStreak);
    final newCoinsWon = isWinner ? current.totalCoinsWon + (stakeCoins * 2) : current.totalCoinsWon;
    final newTier = PvPTier.fromRating(newRating);

    final updatedStats = current.copyWith(
      rating: newRating,
      tier: newTier,
      wins: newWins,
      losses: newLosses,
      draws: newDraws,
      totalMatches: total,
      winRate: total > 0 ? ((newWins / total) * 100.0) : 0.0,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      totalCoinsWon: newCoinsWon,
      favoriteSubject: subject,
    );

    _cachedUserStats = updatedStats;
    return updatedStats;
  }


  /// Fetches the global PvP leaderboard ranking
  static Future<List<PvPStats>> getLeaderboard() async {
    try {
      final response = await ApiService.get(
        '/api/pvp/leaderboard',
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (data['leaderboard'] is List) {
          final rawList = (data['leaderboard'] as List)
              .map((item) => PvPStats.fromJson(item as Map<String, dynamic>))
              .toList();

          // Deduplicate entries strictly by normalized player name (keep highest rating)
          final uniqueMap = <String, PvPStats>{};
          for (final item in rawList) {
            final key = item.name.trim().toLowerCase();
            if (!uniqueMap.containsKey(key) || item.rating > uniqueMap[key]!.rating) {
              uniqueMap[key] = item;
            }
          }

          final list = uniqueMap.values.toList()..sort((a, b) => b.rating.compareTo(a.rating));
          return list;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Leaderboard Error]: $e');
    }


    // Fallback list
    return [
      const PvPStats(
        userId: '1',
        name: 'Grand Archmage Zephyr',
        rating: 2150,
        tier: PvPTier.grandArchmage,
        wins: 142,
        losses: 18,
        draws: 4,
        totalMatches: 164,
        winRate: 86.6,
        currentStreak: 12,
        bestStreak: 21,
        totalCoinsWon: 8500,
        favoriteSubject: 'Computer Science',
      ),
      const PvPStats(
        userId: '2',
        name: 'Lady Ada',
        rating: 1870,
        tier: PvPTier.diamond,
        wins: 98,
        losses: 22,
        draws: 3,
        totalMatches: 123,
        winRate: 79.7,
        currentStreak: 5,
        bestStreak: 14,
        totalCoinsWon: 4900,
        favoriteSubject: 'Mathematics',
      ),
      const PvPStats(
        userId: '3',
        name: 'Quantum Pythagoras',
        rating: 1680,
        tier: PvPTier.platinum,
        wins: 64,
        losses: 26,
        draws: 2,
        totalMatches: 92,
        winRate: 69.5,
        currentStreak: 2,
        bestStreak: 8,
        totalCoinsWon: 3200,
        favoriteSubject: 'Physics',
      ),
      const PvPStats(
        userId: '4',
        name: 'Alchemist Curie',
        rating: 1420,
        tier: PvPTier.gold,
        wins: 45,
        losses: 25,
        draws: 5,
        totalMatches: 75,
        winRate: 60.0,
        currentStreak: 1,
        bestStreak: 7,
        totalCoinsWon: 2250,
        favoriteSubject: 'Chemistry',
      ),
    ];
  }

  /// Fetches pending received and sent friend challenges
  static Future<Map<String, List<PvPChallengeItem>>> getChallenges() async {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final userId = profile.id.isNotEmpty ? profile.id : (profile.name.isNotEmpty ? profile.name : 'demo-user-123');

    try {
      final response = await ApiService.get(
        '/api/pvp/challenges?userId=$userId',
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List<dynamic> rec = data['received'] as List<dynamic>? ?? [];
        final List<dynamic> sent = data['sent'] as List<dynamic>? ?? [];

        return {
          'received': rec.map((e) => PvPChallengeItem.fromJson(e as Map<String, dynamic>)).toList(),
          'sent': sent.map((e) => PvPChallengeItem.fromJson(e as Map<String, dynamic>)).toList(),
        };
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Get Challenges Error]: $e');
    }

    return {'received': [], 'sent': []};
  }

  /// Sends a direct duel challenge to a friend
  static Future<bool> sendChallenge({
    required String challengedId,
    required String subject,
    int stakeCoins = 50,
    String? challengerName,
    String? challengedName,
  }) async {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final userId = profile.id.isNotEmpty ? profile.id : (profile.name.isNotEmpty ? profile.name : 'demo-user-123');

    try {
      final response = await ApiService.post(
        '/api/pvp/challenge',
        body: {
          'challengerId': userId,
          'challengedId': challengedId,
          'subject': subject,
          'stakeCoins': stakeCoins,
          'challengerName': challengerName ?? (profile.name.isNotEmpty ? profile.name : 'Challenger'),
          'challengedName': challengedName ?? 'Friend',
        },
        timeout: _timeout,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [PvPService Send Challenge Error]: $e');
      return false;
    }
  }

  /// Responds to a friend's duel challenge (Accept / Decline)
  static Future<PvPSession?> respondToChallenge({
    required String challengeId,
    required bool accept,
    String? subject,
  }) async {
    final profile = PlayerProfile.current ?? const PlayerProfile();

    try {
      final response = await ApiService.post(
        '/api/pvp/challenges/respond',
        body: {
          'challengeId': challengeId,
          'accept': accept,
          'subject': subject ?? 'Mathematics',
          'grade': profile.grade.isNotEmpty ? profile.grade : 'Class 10',
          'curriculum': profile.curriculum.isNotEmpty ? profile.curriculum : 'CBSE',
        },
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (data['session'] != null) {
          return PvPSession.fromJson(data['session'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Respond Challenge Error]: $e');
    }
    return null;
  }

  /// Marks an active duel challenge as consumed so it does not auto-prompt again
  static Future<void> consumeChallenge({
    required String challengeId,
    String? sessionId,
  }) async {
    try {
      await ApiService.post(
        '/api/pvp/challenges/consume',
        body: {
          'challengeId': challengeId,
          'sessionId': sessionId,
        },
        timeout: const Duration(seconds: 4),
      );
    } catch (_) {}
  }


  /// Fetches an active session by its ID
  static Future<PvPSession?> getSession(String sessionId) async {
    try {
      final response = await ApiService.get(
        '/api/pvp/session/$sessionId',
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (data['session'] != null) {
          return PvPSession.fromJson(data['session'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Get Session Error]: $e');
    }
    return null;
  }

  // ===========================================================================
  // PRIVATE ROOM / MANUAL DUEL METHODS
  // ===========================================================================

  /// Creates a private room code for manual dueling
  static Future<Map<String, dynamic>?> createRoom({
    required String subject,
    required int stakeCoins,
  }) async {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final clientId = await getClientId();
    final effectiveUserId = clientId.isNotEmpty ? clientId : (profile.id.isNotEmpty ? profile.id : 'player-1');
    final effectiveName = profile.name.isNotEmpty ? profile.name : 'Duelist';

    try {
      final response = await ApiService.post(
        '/api/pvp/room/create',
        body: {
          'userId': effectiveUserId,
          'playerName': effectiveName,
          'subject': subject,
          'stakeCoins': stakeCoins,
          'grade': profile.grade.isNotEmpty ? profile.grade : 'Class 10',
          'curriculum': profile.curriculum.isNotEmpty ? profile.curriculum : 'CBSE',
        },
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return data;
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Create Room Error]: $e');
    }
    return null;
  }

  /// Joins a private room code
  static Future<Map<String, dynamic>> joinRoom({
    required String roomCode,
  }) async {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final clientId = await getClientId();
    final effectiveUserId = clientId.isNotEmpty ? clientId : (profile.id.isNotEmpty ? profile.id : 'player-2');
    final effectiveName = profile.name.isNotEmpty ? profile.name : 'Challenger';

    try {
      final response = await ApiService.post(
        '/api/pvp/room/join',
        body: {
          'roomCode': roomCode.trim().toUpperCase(),
          'userId': effectiveUserId,
          'playerName': effectiveName,
        },
        timeout: _timeout,
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['session'] != null) {
        return {
          'success': true,
          'session': PvPSession.fromJson(data['session'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'error': data['error']?.toString() ?? 'Failed to join room',
        };
      }
    } catch (e) {
      debugPrint('⚠️ [PvPService Join Room Error]: $e');
      return {
        'success': false,
        'error': 'Network connection issue or invalid code',
      };
    }
  }

  /// Checks if a friend joined the private room
  static Future<Map<String, dynamic>> getRoomStatus(String roomCode) async {
    try {
      final response = await ApiService.get(
        '/api/pvp/room/status/${roomCode.trim().toUpperCase()}',
        timeout: const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        PvPSession? session;
        if (data['session'] != null) {
          session = PvPSession.fromJson(data['session'] as Map<String, dynamic>);
        }
        return {
          'success': data['success'] == true,
          'status': data['status']?.toString() ?? 'waiting',
          'session': session,
        };
      }
    } catch (_) {}
    return {'success': false, 'status': 'waiting', 'session': null};
  }

  /// Cancels a private room
  static Future<void> cancelRoom(String roomCode) async {
    final clientId = await getClientId();
    try {
      await ApiService.post(
        '/api/pvp/room/cancel',
        body: {'roomCode': roomCode.trim().toUpperCase(), 'userId': clientId},
        timeout: const Duration(seconds: 4),
      );
    } catch (_) {}
  }


  // ===========================================================================
  // OFFLINE FALLBACK DUEL GENERATOR
  // ===========================================================================

  static PvPSession _createOfflineSession(
    String subject,
    int stakeCoins,
    bool isRanked,
    PlayerProfile profile,
  ) {
    final rng = math.Random();
    final questions = _getOfflineQuestions(subject);

    final player = PvPCombatant(
      id: profile.id.isNotEmpty ? profile.id : 'player-1',
      name: profile.name.isNotEmpty ? profile.name : 'Scholar Explorer',
      title: profile.learningGoal.isNotEmpty ? profile.learningGoal : 'Knowledge Archmage',
      avatarInitial: profile.name.isNotEmpty ? profile.name.substring(0, 1).toUpperCase() : 'W',
      avatarColor: const Color(0xFFF2CA50),
      avatarIndex: profile.avatarIndex,
      level: profile.level,
      rating: 1250,
      tier: PvPTier.silver,
      isBot: false,
      hp: 1000,
    );

    final aiTemplates = [
      {'name': 'Archmage Ada', 'title': 'Algorithm Prodigy', 'color': const Color(0xFF60A5FA), 'initial': 'A'},
      {'name': 'Pythagoras AI', 'title': 'Geometric Warden', 'color': const Color(0xFFF2CA50), 'initial': 'P'},
      {'name': 'Scholar Newton', 'title': 'Kinetic Chancellor', 'color': const Color(0xFF82C0A0), 'initial': 'N'},
      {'name': 'Alchemist Curie', 'title': 'Radiant Synthesizer', 'color': const Color(0xFFDEB7FF), 'initial': 'C'},
    ];
    final ai = aiTemplates[rng.nextInt(aiTemplates.length)];

    final opponent = PvPCombatant(
      id: 'ai-scholar-${rng.nextInt(9999)}',
      name: ai['name'] as String,
      title: ai['title'] as String,
      avatarInitial: ai['initial'] as String,
      avatarColor: ai['color'] as Color,
      avatarIndex: rng.nextInt(6),
      level: math.max(1, profile.level + rng.nextInt(3) - 1),
      rating: 1200 + rng.nextInt(100) - 50,
      tier: PvPTier.silver,
      isBot: true,
      hp: 1000,
    );

    return PvPSession(
      id: 'offline-pvp-${DateTime.now().millisecondsSinceEpoch}',
      subject: subject,
      buildingId: 'arena',
      stakeCoins: stakeCoins,
      isRanked: isRanked,
      totalRounds: questions.length,
      currentRound: 0,
      status: 'in_progress',
      combatants: {
        player.id: player,
        opponent.id: opponent,
      },
      questions: questions,
    );
  }

  static List<MCQuestion> _getOfflineQuestions(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return const [
          MCQuestion(
            id: 1,
            question: 'What is the sum of angles in any Euclidean triangle?',
            options: ['180 degrees', '90 degrees', '360 degrees', '270 degrees'],
            correctIndex: 0,
            explanation: 'The interior angles of any planar triangle always sum to exactly 180°.',
          ),
          MCQuestion(
            id: 2,
            question: 'If 2x + 6 = 18, what is the value of x?',
            options: ['6', '4', '8', '12'],
            correctIndex: 0,
            explanation: '2x = 18 - 6 = 12 => x = 6.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the derivative of f(x) = x³ with respect to x?',
            options: ['3x²', 'x²', '3x', '3x³'],
            correctIndex: 0,
            explanation: 'By the power rule, d/dx(x^n) = n*x^(n-1), so d/dx(x³) = 3x².',
          ),
          MCQuestion(
            id: 4,
            question: 'Which of the following is a prime number?',
            options: ['29', '27', '21', '33'],
            correctIndex: 0,
            explanation: '29 has no positive integer divisors other than 1 and itself.',
          ),
          MCQuestion(
            id: 5,
            question: 'What is the hypotenuse of a right triangle with legs of length 6 and 8?',
            options: ['10', '12', '14', '100'],
            correctIndex: 0,
            explanation: 'Using Pythagorean theorem: √(6² + 8²) = √(36 + 64) = √100 = 10.',
          ),
        ];
      case 'computer science':
      case 'programming':
      case 'coding':
        return const [
          MCQuestion(
            id: 1,
            question: 'What is the time complexity of searching in a balanced Binary Search Tree (BST)?',
            options: ['O(log N)', 'O(1)', 'O(N)', 'O(N²)'],
            correctIndex: 0,
            explanation: 'A balanced BST halves the search space at each level, achieving logarithmic time O(log N).',
          ),
          MCQuestion(
            id: 2,
            question: 'Which data structure operates on a Last-In, First-Out (LIFO) principle?',
            options: ['Stack', 'Queue', 'Array', 'Linked List'],
            correctIndex: 0,
            explanation: 'A Stack pushes and pops items from the top in LIFO order.',
          ),
          MCQuestion(
            id: 3,
            question: 'In Flutter/Dart, which keyword is used to mark a function that returns a Future?',
            options: ['async', 'await', 'future', 'defer'],
            correctIndex: 0,
            explanation: 'The `async` keyword designates an asynchronous function returning a Future.',
          ),
          MCQuestion(
            id: 4,
            question: 'Which sorting algorithm has a worst-case time complexity of O(N log N)?',
            options: ['Merge Sort', 'Quick Sort', 'Bubble Sort', 'Insertion Sort'],
            correctIndex: 0,
            explanation: 'Merge Sort consistently divides and merges in O(N log N) even in the worst case.',
          ),
          MCQuestion(
            id: 5,
            question: 'What does HTTP status code 404 signify?',
            options: ['Not Found', 'Unauthorized', 'Server Error', 'Bad Request'],
            correctIndex: 0,
            explanation: 'HTTP 404 indicates the requested server resource was not found.',
          ),
        ];
      case 'physics':
      case 'physics & space':
        return const [
          MCQuestion(
            id: 1,
            question: "What is Newton's Second Law of Motion expressed as a formula?",
            options: ['F = m * a', 'E = mc²', 'v = u + at', 'P = W / t'],
            correctIndex: 0,
            explanation: 'Force equals mass multiplied by acceleration (F = ma).',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the approximate speed of light in a vacuum?',
            options: ['3 x 10⁸ m/s', '3 x 10⁶ m/s', '1.5 x 10⁸ m/s', '3 x 10¹⁰ m/s'],
            correctIndex: 0,
            explanation: 'Light travels at approximately 299,792,458 m/s (~3 x 10⁸ m/s).',
          ),
          MCQuestion(
            id: 3,
            question: 'Which subatomic particle carries a negative electrical charge?',
            options: ['Electron', 'Proton', 'Neutron', 'Photon'],
            correctIndex: 0,
            explanation: 'Electrons have a fundamental electric charge of -1e.',
          ),
          MCQuestion(
            id: 4,
            question: 'What phenomenon causes a pencil in a glass of water to look bent?',
            options: ['Refraction', 'Reflection', 'Diffraction', 'Polarization'],
            correctIndex: 0,
            explanation: 'Refraction is the bending of light as it passes between optical media with different densities.',
          ),
          MCQuestion(
            id: 5,
            question: 'What is the SI unit of electric resistance?',
            options: ['Ohm', 'Volt', 'Ampere', 'Watt'],
            correctIndex: 0,
            explanation: 'Electric resistance is measured in Ohms (Ω).',
          ),
        ];
      default:
        return const [
          MCQuestion(
            id: 1,
            question: 'Which organelle is universally known as the powerhouse of the cell?',
            options: ['Mitochondria', 'Nucleus', 'Ribosome', 'Golgi Body'],
            correctIndex: 0,
            explanation: 'Mitochondria generate ATP chemical energy via cellular respiration.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the atomic number of Carbon?',
            options: ['6', '12', '14', '8'],
            correctIndex: 0,
            explanation: 'Carbon has 6 protons, giving it atomic number 6.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the chemical formula for water?',
            options: ['H₂O', 'CO₂', 'NaCl', 'O₂'],
            correctIndex: 0,
            explanation: 'Water consists of two hydrogen atoms covalently bonded to one oxygen atom.',
          ),
          MCQuestion(
            id: 4,
            question: 'Who developed the General Theory of Relativity?',
            options: ['Albert Einstein', 'Isaac Newton', 'Niels Bohr', 'Galileo Galilei'],
            correctIndex: 0,
            explanation: 'Albert Einstein published the General Theory of Relativity in 1915.',
          ),
          MCQuestion(
            id: 5,
            question: 'What is the primary gas found in Earth’s atmosphere?',
            options: ['Nitrogen (~78%)', 'Oxygen (~21%)', 'Argon (~1%)', 'Carbon Dioxide (~0.04%)'],
            correctIndex: 0,
            explanation: 'Earth’s atmosphere is composed of approximately 78% nitrogen gas (N₂).',
          ),
        ];
    }
  }
}
