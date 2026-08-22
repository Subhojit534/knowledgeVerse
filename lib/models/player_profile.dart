import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the player chooses during onboarding and progression.
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
    this.coins = 500,
    this.gems = 25,
    this.energy = 100,
    this.streakDays = 1,
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
  final int coins;
  final int gems;
  final int energy;
  final int streakDays;

  static PlayerProfile? current;

  static const String _prefsKey = 'playerProfile';
  static const String playerNameKey = 'player_name';
  static const String userIdKey = 'user_id';
  static const String subjectsKey = 'selectedSubjects';
  static const String onboardedKey = 'hasOnboarded';

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
    int? coins,
    int? gems,
    int? energy,
    int? streakDays,
  }) {
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
      xp: xp ?? this.xp,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
      streakDays: streakDays ?? this.streakDays,
    );
  }

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
        'coins': coins,
        'gems': gems,
        'energy': energy,
        'streak_days': streakDays,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
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
      xp: json['xp'] as int? ?? 150,
      level: json['level'] as int? ?? 1,
      coins: json['coins'] as int? ?? 500,
      gems: json['gems'] as int? ?? 25,
      energy: json['energy'] as int? ?? 100,
      streakDays: json['streak_days'] as int? ??
          json['streakDays'] as int? ??
          1,
    );
  }

  /// Payload for POST /api/intro
  Map<String, dynamic> toIntroRequest() {
    final jsonMap = toJson()..remove('avatar_index');
    if (id.isEmpty) jsonMap.remove('id');
    return jsonMap;
  }

  Future<void> save() async {
    current = this;
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
    debugPrint('💾 [PlayerProfile Saved]: Name: "$name", ID: "$id", Level: $level');
  }

  static Future<PlayerProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final profile =
            PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        current = profile;
        debugPrint('📂 [PlayerProfile Loaded]: Name: "${profile.name}", ID: "${profile.id}"');
        return profile;
      } catch (e) {
        debugPrint('⚠️ [PlayerProfile Load Error]: $e');
      }
    }

    final savedName = prefs.getString(playerNameKey)?.trim();
    if (savedName != null && savedName.isNotEmpty) {
      final savedId = prefs.getString(userIdKey)?.trim() ?? '';
      final profile = PlayerProfile(
        id: savedId,
        name: savedName,
      );
      current = profile;
      return profile;
    }

    return null;
  }
}
