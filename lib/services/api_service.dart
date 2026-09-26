import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'curriculum_seed_catalog.dart';

/// Centralized API HTTP Service for KnowledgeVerse.
///
/// Automatically prepends [ApiConfig.baseUrl] to relative endpoints,
/// manages headers, timeouts, error logging, and standard response processing
/// across all application modules:
/// - Authentication
/// - User Profile
/// - Lessons & AI Quiz Engine
/// - Buildings & World
/// - Progress & XP
/// - Leaderboard
/// - Inventory & Equipment
/// - Arcane Shop
/// - Social & Friends
/// - Guilds & Real-time Chat
class ApiService {
  static const Duration _defaultTimeout = Duration(seconds: 60);

  /// Helper to build full URL from relative path
  static Uri _buildUri(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$cleanPath');
  }

  /// Default headers for JSON requests
  static Map<String, String> _buildHeaders([Map<String, String>? customHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  /// Perform a GET request to the backend
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      debugPrint('🌐 [ApiService GET]: $uri');
      final response = await http
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return response;
    } on TimeoutException {
      debugPrint('❌ [ApiService GET Timeout]: $uri');
      rethrow;
    } catch (e) {
      debugPrint('❌ [ApiService GET Error]: $uri -> $e');
      rethrow;
    }
  }

  /// Perform a POST request to the backend
  static Future<http.Response> post(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      debugPrint('🌐 [ApiService POST]: $uri');
      final encodedBody = body is String ? body : jsonEncode(body);
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: encodedBody,
          )
          .timeout(timeout);
      return response;
    } on TimeoutException {
      debugPrint('❌ [ApiService POST Timeout]: $uri');
      rethrow;
    } catch (e) {
      debugPrint('❌ [ApiService POST Error]: $uri -> $e');
      rethrow;
    }
  }

  /// Perform a PUT request to the backend
  static Future<http.Response> put(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      debugPrint('🌐 [ApiService PUT]: $uri');
      final encodedBody = body is String ? body : jsonEncode(body);
      final response = await http
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: encodedBody,
          )
          .timeout(timeout);
      return response;
    } on TimeoutException {
      debugPrint('❌ [ApiService PUT Timeout]: $uri');
      rethrow;
    } catch (e) {
      debugPrint('❌ [ApiService PUT Error]: $uri -> $e');
      rethrow;
    }
  }

  /// Perform a DELETE request to the backend
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      debugPrint('🌐 [ApiService DELETE]: $uri');
      final response = await http
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return response;
    } on TimeoutException {
      debugPrint('❌ [ApiService DELETE Timeout]: $uri');
      rethrow;
    } catch (e) {
      debugPrint('❌ [ApiService DELETE Error]: $uri -> $e');
      rethrow;
    }
  }

  // ===========================================================================
  // MODULE SPECIFIC ROUTE HELPERS
  // ===========================================================================

  /// Authentication endpoints
  static String authRoute(String subpath) => '/api/auth/$subpath';

  /// User Profile endpoints
  static String profileRoute(String subpath) => '/api/profile/$subpath';

  /// Lessons & Learning endpoints
  static String learningRoute(String subpath) => '/api/learning/$subpath';

  /// Leaderboard endpoints
  static String leaderboardRoute(String subpath) => '/api/leaderboard/$subpath';

  /// Inventory endpoints
  static String inventoryRoute(String subpath) => '/api/inventory/$subpath';

  /// Arcane Shop endpoints
  static String shopRoute(String subpath) => '/api/shop/$subpath';

  /// Social endpoints
  static String socialRoute(String subpath) => '/api/social/$subpath';

  /// Guilds endpoints
  static String guildsRoute(String subpath) => '/api/guilds/$subpath';

  /// PvP endpoints
  static String pvpRoute(String subpath) => '/api/pvp/$subpath';

  // ===========================================================================
  // AUTHENTICATION APIs (/api/auth)
  // ===========================================================================

  /// Register a new explorer
  static Future<http.Response> registerExplorer({
    required String name,
    required String password,
    String? classId,
    String? grade,
    String? curriculum,
    String? difficulty,
    String? worldTheme,
    String? learningGoal,
    List<String>? subjects,
  }) async {
    final effectiveGrade = grade ?? 'Class 10';
    final effectiveCurriculum = curriculum ?? 'CBSE';
    final effectiveClassId = (classId != null && classId.isNotEmpty)
        ? classId
        : CurriculumSeedCatalog.findClassId(
            grade: effectiveGrade,
            board: effectiveCurriculum,
          );

    return post(
      '/api/auth/register',
      body: {
        'name': name.trim(),
        'password': password,
        'class_id': effectiveClassId,
        'grade': effectiveGrade,
        'curriculum': effectiveCurriculum,
        'difficulty': difficulty ?? 'Medium',
        'world_theme': worldTheme ?? 'Green Highlands',
        'learning_goal': learningGoal ?? 'Master all academic domains',
        'subjects': (subjects != null && subjects.isNotEmpty)
            ? subjects
            : ['Mathematics', 'Computer Science'],
      },
    );
  }

  /// Login existing explorer
  static Future<http.Response> loginExplorer({
    required String name,
    required String password,
    String? email,
  }) async {
    return post(
      '/api/auth/login',
      body: {
        'name': name.trim(),
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );
  }

  // ===========================================================================
  // PROFILE APIs (/api/profile)
  // ===========================================================================

  /// Retrieve user profile by user UUID
  static Future<http.Response> getProfileById(String userId) async {
    return get('/api/profile/id/$userId');
  }

  /// Retrieve all user profiles
  static Future<http.Response> getAllProfiles() async {
    return get('/api/profile/all');
  }

  /// Save or update user profile
  static Future<http.Response> saveUserProfile(Map<String, dynamic> profileData) async {
    return post('/api/profile', body: profileData);
  }

  // ===========================================================================
  // INVENTORY APIs (/api/inventory)
  // ===========================================================================

  /// Retrieve user inventory and equipped items
  static Future<http.Response> getInventory(String userId) async {
    return get('/api/inventory?userId=${Uri.encodeComponent(userId)}');
  }

  /// Equip an item from inventory
  static Future<http.Response> equipItem({
    required String userId,
    required String itemId,
  }) async {
    return post(
      '/api/inventory/equip',
      body: {'userId': userId, 'itemId': itemId},
    );
  }

  /// Use / consume a potion or consumable item
  static Future<http.Response> useItem({
    required String userId,
    required String itemId,
  }) async {
    return post(
      '/api/inventory/use',
      body: {'userId': userId, 'itemId': itemId},
    );
  }

  // ===========================================================================
  // SHOP APIs (/api/shop)
  // ===========================================================================

  /// Get shop catalog items by category
  static Future<http.Response> getShopItems([String category = 'ALL']) async {
    final query = category.toUpperCase() == 'ALL'
        ? ''
        : '?category=${Uri.encodeComponent(category)}';
    return get('/api/shop/items$query');
  }

  /// Purchase an item from the shop
  static Future<http.Response> purchaseShopItem({
    required String userId,
    required String itemId,
  }) async {
    return post(
      '/api/shop/purchase',
      body: {
        'userId': userId,
        'itemId': itemId,
        'shopItemId': itemId,
      },
    );
  }

  // ===========================================================================
  // LEARNING APIs (/api/learning)
  // ===========================================================================

  /// Fetch learning content & questions via Groq AI / Backend SQL
  static Future<http.Response> getLearningContent(Map<String, dynamic> requestPayload) async {
    final payload = Map<String, dynamic>.from(requestPayload);
    if ((payload['subtopic_id'] == null || payload['subtopic_id'].toString().isEmpty) &&
        (payload['topic_id'] == null || payload['topic_id'].toString().isEmpty)) {
      final subject = payload['subject']?.toString() ?? '';
      final grade = payload['grade']?.toString() ?? 'Class 10';
      final matchingTopics = CurriculumSeedCatalog.getTopicsFor(subject: subject, grade: grade);
      if (matchingTopics.isNotEmpty) {
        payload['topic_id'] = matchingTopics.first.id;
        if (matchingTopics.first.subtopics.isNotEmpty) {
          payload['subtopic_id'] = matchingTopics.first.subtopics.first.id;
        }
      } else {
        payload['topic_id'] = 'b0000010-0001-0000-0000-000000000041';
        payload['subtopic_id'] = 'c0000010-0001-0000-0000-000000000081';
      }
    }
    return post('/api/learning/content', body: payload);
  }

  /// Submit quiz score and earn XP & coins
  static Future<http.Response> submitQuizScore(Map<String, dynamic> quizPayload) async {
    return post('/api/learning/submit-quiz', body: quizPayload);
  }

  /// TTS endpoint for learning text
  static Future<http.Response> getTtsAudio(String text) async {
    return post('/api/learning/tts', body: {'text': text});
  }

  // ===========================================================================
  // CLASSES APIs (/api/classes)
  // ===========================================================================

  /// Fetch classes filtered by curriculum board (e.g. CBSE, ICSE, BSEB, WBBSE, DBSE)
  static Future<http.Response> getClasses({String? board}) async {
    final query = (board != null && board.trim().isNotEmpty)
        ? '?board=${Uri.encodeComponent(board.trim().toUpperCase())}'
        : '';
    return get('/api/classes$query');
  }

  // ===========================================================================
  // SOCIAL APIs (/api/social)
  // ===========================================================================

  /// Get comprehensive social dashboard data (friends, requests, explorers, guild overview)
  static Future<http.Response> getSocialDashboard(String userId) async {
    return get('/api/social/dashboard?userId=${Uri.encodeComponent(userId)}');
  }

  /// Get friends, incoming requests, sent requests, and discoverable explorers
  static Future<http.Response> getFriends(String userId) async {
    return get('/api/social/friends?userId=${Uri.encodeComponent(userId)}');
  }

  /// Send friend invitation
  static Future<http.Response> sendFriendRequest({
    required String requesterId,
    required String addresseeId,
  }) async {
    return post(
      '/api/social/friends/request',
      body: {
        'requesterId': requesterId,
        'addresseeId': addresseeId,
      },
    );
  }

  /// Accept or decline a friend invitation
  static Future<http.Response> respondFriendRequest({
    required String friendshipId,
    required bool accept,
  }) async {
    return post(
      '/api/social/friends/respond',
      body: {
        'friendshipId': friendshipId,
        'accept': accept,
      },
    );
  }

  /// Challenge a friend directly to a quiz duel
  static Future<http.Response> challengeFriendDuel({
    required String challengerId,
    required String challengedId,
    required String buildingId,
    required String subject,
    int stakeCoins = 50,
  }) async {
    return post(
      '/api/social/duel/challenge',
      body: {
        'challengerId': challengerId,
        'challengedId': challengedId,
        'buildingId': buildingId,
        'subject': subject,
        'stakeCoins': stakeCoins,
      },
    );
  }

  // ===========================================================================
  // GUILDS APIs (/api/guilds)
  // ===========================================================================

  /// Get public guild directory
  static Future<http.Response> getPublicGuilds() async {
    return get('/api/guilds');
  }

  /// Get player's active guild, roster, and chat feed
  static Future<http.Response> getMyGuild(String userId) async {
    return get('/api/guilds/my?userId=${Uri.encodeComponent(userId)}');
  }

  /// Create a new scholar guild
  static Future<http.Response> createGuild({
    required String leaderId,
    required String name,
    required String tag,
    required String motto,
  }) async {
    return post(
      '/api/guilds/create',
      body: {
        'leaderId': leaderId,
        'name': name,
        'tag': tag,
        'motto': motto,
      },
    );
  }

  /// Join an existing guild
  static Future<http.Response> joinGuild({
    required String userId,
    required String guildId,
  }) async {
    return post(
      '/api/guilds/join',
      body: {
        'userId': userId,
        'guildId': guildId,
      },
    );
  }

  /// Leave current guild
  static Future<http.Response> leaveGuild({
    required String userId,
    required String guildId,
  }) async {
    return post(
      '/api/guilds/leave',
      body: {
        'userId': userId,
        'guildId': guildId,
      },
    );
  }

  /// Poll live chat messages for a guild
  static Future<http.Response> getGuildMessages(String guildId) async {
    return get('/api/guilds/messages?guildId=${Uri.encodeComponent(guildId)}');
  }

  /// Post a message to guild chat
  static Future<http.Response> sendGuildMessage({
    required String guildId,
    required String senderId,
    required String text,
  }) async {
    return post(
      '/api/guilds/chat',
      body: {
        'guildId': guildId,
        'senderId': senderId,
        'text': text,
      },
    );
  }

  // ===========================================================================
  // MULTIPLAYER PVP APIs (/api/pvp)
  // ===========================================================================

  /// Queue for PvP matchmaking or instant pairing
  static Future<http.Response> matchmakePvP({
    required String userId,
    required String playerName,
    required String subject,
    int stakeCoins = 50,
    bool isRanked = true,
    String grade = 'Class 10',
    String curriculum = 'CBSE',
  }) async {
    return post(
      '/api/pvp/matchmake',
      body: {
        'userId': userId,
        'playerName': playerName,
        'subject': subject,
        'stakeCoins': stakeCoins,
        'isRanked': isRanked,
        'grade': grade,
        'curriculum': curriculum,
      },
    );
  }

  /// Cancel active matchmaking search
  static Future<http.Response> cancelPvPMatchmaking(String userId) async {
    return post(
      '/api/pvp/matchmake/cancel',
      body: {'userId': userId},
    );
  }

  /// Create a private PvP duel room
  static Future<http.Response> createPvPRoom({
    required String userId,
    required String playerName,
    required String subject,
    int stakeCoins = 50,
    String grade = 'Class 10',
    String curriculum = 'CBSE',
  }) async {
    return post(
      '/api/pvp/room/create',
      body: {
        'userId': userId,
        'playerName': playerName,
        'subject': subject,
        'stakeCoins': stakeCoins,
        'grade': grade,
        'curriculum': curriculum,
      },
    );
  }

  /// Join an existing private PvP duel room via 6-digit room code
  static Future<http.Response> joinPvPRoom({
    required String roomCode,
    required String userId,
    required String playerName,
  }) async {
    return post(
      '/api/pvp/room/join',
      body: {
        'roomCode': roomCode.trim().toUpperCase(),
        'userId': userId,
        'playerName': playerName,
      },
    );
  }

  /// Check room readiness / status
  static Future<http.Response> getPvPRoomStatus(String roomCode) async {
    return get('/api/pvp/room/status/${Uri.encodeComponent(roomCode.trim().toUpperCase())}');
  }

  /// Cancel and dismantle an active duel room
  static Future<http.Response> cancelPvPRoom({
    required String roomCode,
    required String userId,
  }) async {
    return post(
      '/api/pvp/room/cancel',
      body: {
        'roomCode': roomCode.trim().toUpperCase(),
        'userId': userId,
      },
    );
  }

  /// Retrieve current PvP match session state
  static Future<http.Response> getPvPSession(String sessionId) async {
    return get('/api/pvp/session/${Uri.encodeComponent(sessionId)}');
  }

  /// Submit answer for current battle round
  static Future<http.Response> submitPvPRound({
    required String sessionId,
    required String userId,
    required int roundIndex,
    required int selectedIndex,
    required int timeTakenMs,
  }) async {
    return post(
      '/api/pvp/session/${Uri.encodeComponent(sessionId)}/round',
      body: {
        'user_id': userId,
        'round_index': roundIndex,
        'selected_index': selectedIndex,
        'time_taken_ms': timeTakenMs,
      },
    );
  }

  /// Complete and conclude a PvP match session
  static Future<http.Response> finishPvPSession(String sessionId) async {
    return post('/api/pvp/session/${Uri.encodeComponent(sessionId)}/finish');
  }

  /// Send a direct PvP challenge to another player
  static Future<http.Response> sendPvPChallenge({
    required String challengerId,
    required String challengedId,
    required String subject,
    int stakeCoins = 50,
    String? challengerName,
    String? challengedName,
  }) async {
    return post(
      '/api/pvp/challenge',
      body: {
        'challengerId': challengerId,
        'challengedId': challengedId,
        'subject': subject,
        'stakeCoins': stakeCoins,
        if (challengerName != null) 'challengerName': challengerName,
        if (challengedName != null) 'challengedName': challengedName,
      },
    );
  }

  /// Get list of incoming pending challenges
  static Future<http.Response> getPendingPvPChallenges(String userId) async {
    return get('/api/pvp/challenges?userId=${Uri.encodeComponent(userId)}');
  }

  /// Respond to a pending PvP challenge (accept/decline)
  static Future<http.Response> respondToPvPChallenge({
    required String challengeId,
    required bool accept,
    String grade = 'Class 10',
    String curriculum = 'CBSE',
    String subject = 'Mathematics',
  }) async {
    return post(
      '/api/pvp/challenges/respond',
      body: {
        'challengeId': challengeId,
        'accept': accept,
        'grade': grade,
        'curriculum': curriculum,
        'subject': subject,
      },
    );
  }

  /// Consume an accepted challenge once both players launch the arena
  static Future<http.Response> consumePvPChallenge({
    required String challengeId,
    required String sessionId,
  }) async {
    return post(
      '/api/pvp/challenges/consume',
      body: {
        'challengeId': challengeId,
        'sessionId': sessionId,
      },
    );
  }

  /// Get player's PvP duel combat statistics
  static Future<http.Response> getPvPStats(String userId) async {
    return get('/api/pvp/stats/${Uri.encodeComponent(userId)}');
  }

  /// Get PvP ranked duelist leaderboard
  static Future<http.Response> getPvPLeaderboard() async {
    return get('/api/pvp/leaderboard');
  }

  // ===========================================================================
  // LEADERBOARD APIs (/api/leaderboard)
  // ===========================================================================

  /// Get general leaderboard rankings
  static Future<http.Response> getLeaderboard([String category = 'GLOBAL']) async {
    final query = category.toUpperCase() == 'GLOBAL'
        ? ''
        : '?category=${Uri.encodeComponent(category)}';
    return get('/api/leaderboard$query');
  }
}


