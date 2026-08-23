import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

/// Global reactive notifier for real-time player profile updates
class PlayerProfileNotifier extends ValueNotifier<PlayerProfile?> {
  PlayerProfileNotifier(super.value);

  void update(PlayerProfile p) {
    value = p;
    PlayerProfile.current = p;
    notifyListeners();
  }
}

/// Everything the player chooses during onboarding, progression, and live gameplay economy.
/// Backed by local persistent storage and real-time Supabase cloud synchronization.
class PlayerProfile {
  const PlayerProfile({
    this.id = '',
    this.name = '',
    this.password = '',
    this.grade = '',
    this.curriculum = '',
    this.subjects = const [],
    this.difficulty = '',
    this.worldTheme = '',
    this.learningGoal = '',
    this.avatarIndex = 0,
    this.xp = 150,
    this.level = 1,
    this.focusXp = 150,
    this.coins = 500,
    this.gems = 25,
    this.energy = 100,
    this.streakDays = 1,
    this.lastLoginDate = '',
    this.weeklyQuestions = 12,
    this.weeklyMinutes = 45,
    this.lastEnergyUpdate = 0,
    this.ownedItems = const [],
  });

  final String id;
  final String name;
  final String password;
  final String grade;
  final String curriculum;
  final List<String> subjects;
  final String difficulty;
  final String worldTheme;
  final String learningGoal;
  final int avatarIndex;
  final int xp;
  final int level;
  final int focusXp;
  final int coins;
  final int gems;
  final int energy;
  final int streakDays;
  final String lastLoginDate;
  final int weeklyQuestions;
  final int weeklyMinutes;
  final int lastEnergyUpdate;
  final List<String> ownedItems;

  static PlayerProfile? current;

  /// Global reactive notifier for real-time HUD and UI updates across the entire app
  static final PlayerProfileNotifier notifier = PlayerProfileNotifier(null);

  /// Background recurring timer for live energy regeneration (2 energy per minute)
  static Timer? _energyRegenTimer;

  static const String _prefsKey = 'playerProfile';
  static const String playerNameKey = 'player_name';
  static const String userIdKey = 'user_id';
  static const String subjectsKey = 'selectedSubjects';
  static const String onboardedKey = 'hasOnboarded';

  /// XP required to complete a given level: 1000 XP for Level 1, 1000 + (lvl * 1000) for subsequent levels
  static int xpRequiredForLevel(int lvl) {
    if (lvl <= 1) return 1000;
    return 1000 + (lvl * 1000);
  }

  /// Calculates player level from total cumulative XP
  static int computeLevel(int totalXp) {
    if (totalXp < 0) return 1;
    int currentLvl = 1;
    int remainingXp = totalXp;
    while (true) {
      final int needed = xpRequiredForLevel(currentLvl);
      if (remainingXp >= needed) {
        remainingXp -= needed;
        currentLvl++;
      } else {
        break;
      }
    }
    return currentLvl;
  }

  /// XP into current level
  int get currentLevelXp {
    if (xp < 0) return 0;
    int currentLvl = 1;
    int remainingXp = xp;
    while (true) {
      final int needed = xpRequiredForLevel(currentLvl);
      if (remainingXp >= needed) {
        remainingXp -= needed;
        currentLvl++;
      } else {
        return remainingXp;
      }
    }
  }

  /// Total XP needed for current level tier
  int get nextLevelXpRequired => xpRequiredForLevel(level);

  /// Progress ratio to next level [0.0 to 1.0]
  double get levelProgressRatio {
    final needed = nextLevelXpRequired;
    return needed > 0 ? (currentLevelXp / needed).clamp(0.0, 1.0) : 0.0;
  }

  PlayerProfile copyWith({
    String? id,
    String? name,
    String? password,
    String? grade,
    String? curriculum,
    List<String>? subjects,
    String? difficulty,
    String? worldTheme,
    String? learningGoal,
    int? avatarIndex,
    int? xp,
    int? level,
    int? focusXp,
    int? coins,
    int? gems,
    int? energy,
    int? streakDays,
    String? lastLoginDate,
    int? weeklyQuestions,
    int? weeklyMinutes,
    int? lastEnergyUpdate,
    List<String>? ownedItems,
  }) {
    final newXp = xp ?? this.xp;
    final newLevel = level ?? computeLevel(newXp);

    return PlayerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      grade: grade ?? this.grade,
      curriculum: curriculum ?? this.curriculum,
      subjects: subjects ?? this.subjects,
      difficulty: difficulty ?? this.difficulty,
      worldTheme: worldTheme ?? this.worldTheme,
      learningGoal: learningGoal ?? this.learningGoal,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      xp: newXp,
      level: newLevel,
      focusXp: focusXp ?? this.focusXp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
      streakDays: streakDays ?? this.streakDays,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      weeklyQuestions: weeklyQuestions ?? this.weeklyQuestions,
      weeklyMinutes: weeklyMinutes ?? this.weeklyMinutes,
      lastEnergyUpdate: lastEnergyUpdate ?? this.lastEnergyUpdate,
      ownedItems: ownedItems ?? this.ownedItems,
    );
  }

  /// Applies daily login streak logic
  PlayerProfile withDailyStreak() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (lastLoginDate.isEmpty) {
      return copyWith(lastLoginDate: todayStr, streakDays: 1);
    }

    if (lastLoginDate == todayStr) {
      return this;
    }

    try {
      final lastDate = DateTime.parse(lastLoginDate);
      final difference = DateTime(now.year, now.month, now.day).difference(
        DateTime(lastDate.year, lastDate.month, lastDate.day),
      ).inDays;

      if (difference == 1) {
        return copyWith(
          lastLoginDate: todayStr,
          streakDays: streakDays + 1,
        );
      } else if (difference > 1) {
        return copyWith(
          lastLoginDate: todayStr,
          streakDays: 1,
        );
      }
    } catch (_) {}

    return copyWith(lastLoginDate: todayStr);
  }

  /// Regenerates +1 energy per elapsed minute up to 100 limit, and +1 Focus XP per minute
  PlayerProfile withEnergyRegeneration() {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    if (lastEnergyUpdate <= 0) {
      return copyWith(lastEnergyUpdate: nowMillis);
    }

    final int elapsedMillis = nowMillis - lastEnergyUpdate;
    final int elapsedMinutes = (elapsedMillis / 60000).floor();
    if (elapsedMinutes <= 0) {
      return this;
    }

    if (energy >= 100) {
      return copyWith(lastEnergyUpdate: nowMillis);
    }

    final int newEnergy = math.min(100, energy + (elapsedMinutes * 1));
    final int newFocusXp = focusXp + (elapsedMinutes * 1);
    final int remainderMillis = elapsedMillis % 60000;
    final int updatedLastTime = nowMillis - remainderMillis;

    return copyWith(
      energy: newEnergy,
      focusXp: newFocusXp,
      lastEnergyUpdate: updatedLastTime,
    );
  }

  /// Awards +10 coins, +50 XP, +50 Focus XP, increments weekly questions, and auto-calculates level
  PlayerProfile withCorrectAnswer() {
    final updatedXp = xp + 50;
    return copyWith(
      coins: coins + 10,
      xp: updatedXp,
      focusXp: focusXp + 50,
      level: computeLevel(updatedXp),
      weeklyQuestions: weeklyQuestions + 1,
    );
  }

  /// On wrong answer: energy decreases by 1 (stops at 0), no coins or XP awarded
  PlayerProfile withWrongAnswer() {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    return copyWith(
      energy: math.max(0, energy - 1),
      lastEnergyUpdate: lastEnergyUpdate > 0 ? lastEnergyUpdate : nowMillis,
    );
  }

  /// Awards +5 diamonds/gems on perfect 4/4 quiz completion
  PlayerProfile withPerfectQuizReward() {
    return copyWith(
      gems: gems + 5,
    );
  }

  /// Adds purchased item to owned inventory and deducts price
  PlayerProfile withPurchasedItem({
    required String itemId,
    required int price,
    required String currency,
  }) {
    final newOwned = List<String>.from(ownedItems);
    if (!newOwned.contains(itemId)) {
      newOwned.add(itemId);
    }

    if (currency.toUpperCase() == 'COINS') {
      return copyWith(
        coins: math.max(0, coins - price),
        ownedItems: newOwned,
      );
    } else {
      return copyWith(
        gems: math.max(0, gems - price),
        ownedItems: newOwned,
      );
    }
  }

  bool isItemOwned(String itemId) => ownedItems.contains(itemId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'password': password,
        'grade': grade,
        'curriculum': curriculum,
        'subjects': subjects,
        'difficulty': difficulty,
        'world_theme': worldTheme,
        'learning_goal': learningGoal,
        'avatar_index': avatarIndex,
        'xp': xp,
        'level': level,
        'focus_xp': focusXp,
        'coins': coins,
        'gems': gems,
        'energy': energy,
        'streak_days': streakDays,
        'last_login_date': lastLoginDate,
        'weekly_questions': weeklyQuestions,
        'weekly_minutes': weeklyMinutes,
        'last_energy_update': lastEnergyUpdate,
        'owned_items': ownedItems,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final rawXp = json['xp'] as int? ?? 150;
    final computedLvl = json['level'] as int? ?? computeLevel(rawXp);

    return PlayerProfile(
      id: json['id'] as String? ?? '',
      name: (json['name'] as String? ?? '').trim(),
      password: json['password'] as String? ?? '',
      grade: json['grade'] as String? ?? 'Class 10',
      curriculum: json['curriculum'] as String? ?? 'CBSE',
      subjects:
          (json['subjects'] as List?)?.map((e) => e.toString()).toList() ??
              ['Mathematics', 'Computer Science'],
      difficulty: json['difficulty'] as String? ?? 'Balanced',
      worldTheme: json['world_theme'] as String? ??
          json['worldTheme'] as String? ??
          'Green Highlands',
      learningGoal: json['learning_goal'] as String? ??
          json['learningGoal'] as String? ??
          'Civilization Architect',
      avatarIndex: json['avatar_index'] as int? ??
          json['avatarIndex'] as int? ??
          0,
      xp: rawXp,
      level: computedLvl,
      focusXp: json['focus_xp'] as int? ?? rawXp,
      coins: json['coins'] as int? ?? 500,
      gems: json['gems'] as int? ?? 25,
      energy: json['energy'] as int? ?? 100,
      streakDays: json['streak_days'] as int? ??
          json['streakDays'] as int? ??
          1,
      lastLoginDate: json['last_login_date'] as String? ?? '',
      weeklyQuestions: json['weekly_questions'] as int? ?? 12,
      weeklyMinutes: json['weekly_minutes'] as int? ?? 45,
      lastEnergyUpdate: json['last_energy_update'] as int? ?? 0,
      ownedItems: (json['owned_items'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// Payload for POST /api/intro
  Map<String, dynamic> toIntroRequest() {
    final jsonMap = toJson()..remove('avatar_index');
    if (id.isEmpty) jsonMap.remove('id');
    return jsonMap;
  }

  /// Save locally to SharedPreferences, notify all UI listeners, and synchronize with Supabase DB
  Future<void> save() async {
    current = this;
    notifier.update(this);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toJson()));
    if (name.isNotEmpty) {
      await prefs.setString(playerNameKey, name);
    }
    if (id.isNotEmpty) {
      await prefs.setString(userIdKey, id);
    }
    await prefs.setStringList(subjectsKey, subjects);
    await prefs.setBool(onboardedKey, true);
    debugPrint('💾 [PlayerProfile Saved]: Name: "$name", Level: $level, XP: $xp, Coins: $coins, Gems: $gems, Energy: $energy, Streak: $streakDays');

    // Asynchronously synchronize with Backend DB
    _syncWithDb();
  }

  void _syncWithDb() {
    final targetId = id.isNotEmpty ? id : name;
    if (targetId.isEmpty) return;

    Future(() async {
      try {
        final res = await ApiService.put('/api/profile/me?userId=$targetId', body: toJson());
        if (res.statusCode == 200) {
          debugPrint('☁️ [PlayerProfile DB Sync]: Successfully synchronized profile with DB');
        }
      } catch (err) {
        debugPrint('⚠️ [PlayerProfile DB Sync Warning]: $err');
      }
    });
  }

  /// Helper to atomically update the current profile, notify listeners, and sync with DB
  static Future<PlayerProfile> update(PlayerProfile Function(PlayerProfile current) updateFn) async {
    final base = current ?? await load() ?? const PlayerProfile();
    final updated = updateFn(base);
    await updated.save();
    return updated;
  }

  /// Starts live recurring background timer that checks every 10 seconds and regenerates 2 energy per elapsed minute
  static void startEnergyRegenLoop() {
    _energyRegenTimer?.cancel();
    _energyRegenTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final profile = current;
      if (profile != null && profile.energy < 100) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (profile.lastEnergyUpdate <= 0) {
          profile.copyWith(lastEnergyUpdate: now).save();
          return;
        }
        final elapsedMinutes = ((now - profile.lastEnergyUpdate) / 60000).floor();
        if (elapsedMinutes >= 1) {
          final updated = profile.withEnergyRegeneration();
          updated.save();
          debugPrint('⚡ [Energy Regenerated]: +${elapsedMinutes * 1} Energy (Total: ${updated.energy}/100)');
        }
      }
    });
  }

  static Future<PlayerProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    PlayerProfile? profile;

    if (raw != null && raw.isNotEmpty) {
      try {
        profile = PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        profile = profile.withDailyStreak().withEnergyRegeneration();
      } catch (e) {
        debugPrint('⚠️ [PlayerProfile Load Error]: $e');
      }
    }

    if (profile == null) {
      var savedId = prefs.getString(userIdKey)?.trim();
      var savedName = prefs.getString(playerNameKey)?.trim();
      if (savedId == null || savedId.isEmpty) {
        final randCode = math.Random().nextInt(9000) + 1000;
        savedId = 'duelist_${DateTime.now().millisecondsSinceEpoch % 100000}_$randCode';
        await prefs.setString(userIdKey, savedId);
      }
      if (savedName == null || savedName.isEmpty) {
        final randNum = savedId.split('_').last;
        savedName = 'Duelist_$randNum';
        await prefs.setString(playerNameKey, savedName);
      }
      profile = PlayerProfile(
        id: savedId,
        name: savedName,
      );
      profile = profile.withDailyStreak().withEnergyRegeneration();
      await prefs.setString(_prefsKey, jsonEncode(profile.toJson()));
    } else if (profile.id.isEmpty) {
      var savedId = prefs.getString(userIdKey)?.trim();
      if (savedId == null || savedId.isEmpty) {
        final randCode = math.Random().nextInt(9000) + 1000;
        savedId = 'duelist_${DateTime.now().millisecondsSinceEpoch % 100000}_$randCode';
        await prefs.setString(userIdKey, savedId);
      }
      profile = profile.copyWith(id: savedId);
      await prefs.setString(_prefsKey, jsonEncode(profile.toJson()));
    }

    if (profile != null) {
      current = profile;
      notifier.update(profile);
      debugPrint('📂 [PlayerProfile Loaded]: ID: "${profile.id}", Name: "${profile.name}", Level: ${profile.level}, Coins: ${profile.coins}');

      // Ensure live energy regeneration timer is active
      startEnergyRegenLoop();

      // Fetch latest profile from DB in background to keep state synchronized
      _fetchServerProfile(profile);
      return profile;
    }

    return null;
  }


  static void _fetchServerProfile(PlayerProfile localProfile) {
    final targetId = localProfile.id.isNotEmpty ? localProfile.id : localProfile.name;
    if (targetId.isEmpty) return;

    Future(() async {
      try {
        final res = await ApiService.get('/api/profile/me?userId=$targetId');
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          final p = data['profile'] as Map<String, dynamic>?;
          if (p != null) {
            final serverXp = p['xp'] as int? ?? 0;
            final serverCoins = p['coins'] as int? ?? 0;
            final serverGems = p['gems'] as int? ?? 0;

            final maxXp = math.max(localProfile.xp, serverXp);
            final maxCoins = math.max(localProfile.coins, serverCoins);
            final maxGems = math.max(localProfile.gems, serverGems);

            final merged = localProfile.copyWith(
              xp: maxXp,
              level: computeLevel(maxXp),
              coins: maxCoins,
              gems: maxGems,
              energy: p['energy'] as int? ?? localProfile.energy,
              streakDays: p['streak_days'] as int? ?? localProfile.streakDays,
            );
            current = merged;
            notifier.update(merged);
          }
        }
      } catch (_) {}
    });
  }
}
