import 'package:flutter/material.dart';
import 'learning_models.dart';

/// PvP League Tiers for competitive duels
enum PvPTier {
  bronze('Bronze Scholar', Color(0xFFCD7F32), Icons.shield_outlined, 0, 1099),
  silver('Silver Adept', Color(0xFFC0C0C0), Icons.verified_outlined, 1100, 1299),
  gold('Gold Mage', Color(0xFFF2CA50), Icons.workspace_premium, 1300, 1499),
  platinum('Platinum Sorcerer', Color(0xFF70D6FF), Icons.auto_awesome, 1500, 1699),
  diamond('Diamond Arcanist', Color(0xFFB388FF), Icons.diamond_outlined, 1700, 1899),
  grandArchmage('Grand Archmage', Color(0xFFFF6B6B), Icons.military_tech, 1900, 9999);

  final String label;
  final Color color;
  final IconData icon;
  final int minRating;
  final int maxRating;

  const PvPTier(this.label, this.color, this.icon, this.minRating, this.maxRating);

  static PvPTier fromRating(int rating) {
    if (rating >= 1900) return PvPTier.grandArchmage;
    if (rating >= 1700) return PvPTier.diamond;
    if (rating >= 1500) return PvPTier.platinum;
    if (rating >= 1300) return PvPTier.gold;
    if (rating >= 1100) return PvPTier.silver;
    return PvPTier.bronze;
  }

  static PvPTier fromString(String str) {
    final clean = str.trim().toLowerCase();
    if (clean.contains('archmage')) return PvPTier.grandArchmage;
    if (clean.contains('diamond')) return PvPTier.diamond;
    if (clean.contains('platinum')) return PvPTier.platinum;
    if (clean.contains('gold')) return PvPTier.gold;
    if (clean.contains('silver')) return PvPTier.silver;
    return PvPTier.bronze;
  }
}

/// Represents one duelist combatant in a live/simulated PvP battle
class PvPCombatant {
  final String id;
  final String name;
  final String title;
  final String avatarInitial;
  final Color avatarColor;
  final int avatarIndex;
  final int level;
  final int rating;
  final PvPTier tier;
  final bool isBot;
  int hp; // Maximum 1000 HP
  int score;
  int correctCount;
  int avgTimeMs;

  PvPCombatant({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarInitial,
    required this.avatarColor,
    required this.avatarIndex,
    required this.level,
    required this.rating,
    required this.tier,
    required this.isBot,
    this.hp = 1000,
    this.score = 0,
    this.correctCount = 0,
    this.avgTimeMs = 0,
  });

  factory PvPCombatant.fromJson(Map<String, dynamic> json) {
    Color parseColor(dynamic c) {
      if (c == null) return const Color(0xFF60A5FA);
      if (c is Color) return c;
      if (c is String) {
        final hex = c.replaceAll('#', '');
        if (hex.length == 6) {
          try {
            return Color(int.parse('0xFF$hex'));
          } catch (_) {}
        }
      }
      return const Color(0xFF60A5FA);
    }

    final r = (json['rating'] as num?)?.toInt() ?? 1200;
    final nameStr = json['name']?.toString() ?? 'Opponent';

    return PvPCombatant(
      id: json['id']?.toString() ?? '',
      name: nameStr,
      title: json['title']?.toString() ?? 'Academy Duelist',
      avatarInitial: json['avatar_initial']?.toString() ??
          json['avatarInitial']?.toString() ??
          (nameStr.isNotEmpty ? nameStr.substring(0, 1).toUpperCase() : 'E'),
      avatarColor: parseColor(json['avatar_color'] ?? json['avatarColor']),
      avatarIndex: (json['avatar_index'] as num? ?? json['avatarIndex'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      rating: r,
      tier: json['tier'] != null ? PvPTier.fromString(json['tier'].toString()) : PvPTier.fromRating(r),
      isBot: json['is_bot'] as bool? ?? json['isBot'] as bool? ?? false,
      hp: (json['hp'] as num?)?.toInt() ?? 1000,
      score: (json['score'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num? ?? json['correctCount'] as num?)?.toInt() ?? 0,
      avgTimeMs: (json['avg_time_ms'] as num? ?? json['avgTimeMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'avatar_initial': avatarInitial,
        'avatar_color': '#${avatarColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        'avatar_index': avatarIndex,
        'level': level,
        'rating': rating,
        'tier': tier.label,
        'is_bot': isBot,
        'hp': hp,
        'score': score,
        'correct_count': correctCount,
        'avg_time_ms': avgTimeMs,
      };
}

/// Represents the synchronized live PvP duel session state
class PvPSession {
  final String id;
  final String subject;
  final String buildingId;
  final int stakeCoins;
  final bool isRanked;
  final int totalRounds;
  int currentRound;
  String status; // waiting, in_progress, completed
  final Map<String, PvPCombatant> combatants;
  final List<MCQuestion> questions;
  String? winnerId;
  bool isDraw;
  Map<String, dynamic>? rewards;

  PvPSession({
    required this.id,
    required this.subject,
    required this.buildingId,
    required this.stakeCoins,
    required this.isRanked,
    required this.totalRounds,
    this.currentRound = 0,
    this.status = 'in_progress',
    required this.combatants,
    required this.questions,
    this.winnerId,
    this.isDraw = false,
    this.rewards,
  });

  factory PvPSession.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawCombatants =
        json['combatants'] is Map ? (json['combatants'] as Map<String, dynamic>) : {};
    final Map<String, PvPCombatant> parsedCombatants = {};

    rawCombatants.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        try {
          parsedCombatants[key] = PvPCombatant.fromJson(value);
        } catch (e) {
          debugPrint('⚠️ [Combatant parse error]: $e');
        }
      }
    });

    final List<dynamic> rawQuestions = (json['questions'] as List<dynamic>?) ?? [];
    final List<MCQuestion> parsedQuestions = [];
    for (final q in rawQuestions) {
      if (q is Map<String, dynamic>) {
        try {
          parsedQuestions.add(MCQuestion.fromJson(q));
        } catch (e) {
          debugPrint('⚠️ [MCQuestion parse error]: $e');
        }
      }
    }

    // Default questions if empty
    if (parsedQuestions.isEmpty) {
      parsedQuestions.addAll([
        const MCQuestion(
          id: 1,
          question: 'What is the value of 2³ × 2²?',
          options: ['32', '16', '64', '8'],
          correctIndex: 0,
          explanation: 'Using exponent addition: 2^(3+2) = 2^5 = 32.',
        ),
        const MCQuestion(
          id: 2,
          question: 'If 3x - 7 = 14, what is the value of x?',
          options: ['7', '5', '9', '6'],
          correctIndex: 0,
          explanation: '3x = 21 -> x = 7.',
        ),
      ]);
    }

    return PvPSession(
      id: json['id']?.toString() ?? 'session-${DateTime.now().millisecondsSinceEpoch}',
      subject: json['subject']?.toString() ?? 'Mathematics',
      buildingId: json['building_id']?.toString() ?? json['buildingId']?.toString() ?? 'arena',
      stakeCoins: (json['stake_coins'] as num? ?? json['stakeCoins'] as num?)?.toInt() ?? 50,
      isRanked: json['is_ranked'] as bool? ?? json['isRanked'] as bool? ?? true,
      totalRounds: (json['total_rounds'] as num? ?? json['totalRounds'] as num?)?.toInt() ?? parsedQuestions.length,
      currentRound: (json['current_round'] as num? ?? json['currentRound'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'in_progress',
      combatants: parsedCombatants,
      questions: parsedQuestions,
      winnerId: json['winner_id']?.toString() ?? json['winnerId']?.toString(),
      isDraw: json['is_draw'] as bool? ?? json['isDraw'] as bool? ?? false,
      rewards: json['rewards'] as Map<String, dynamic>?,
    );
  }
}

/// Instant feedback result from submitting one round's answer
class PvPRoundResult {
  final int round;
  final String userId;
  final bool isCorrect;
  final int damageDealt;
  final int scoreAwarded;
  final int opponentDamageDealt;
  final bool opponentIsCorrect;
  final int opponentScoreAwarded;

  const PvPRoundResult({
    required this.round,
    required this.userId,
    required this.isCorrect,
    required this.damageDealt,
    required this.scoreAwarded,
    required this.opponentDamageDealt,
    required this.opponentIsCorrect,
    required this.opponentScoreAwarded,
  });

  factory PvPRoundResult.fromJson(Map<String, dynamic> json) {
    return PvPRoundResult(
      round: (json['round'] as num? ?? json['round_index'] as num? ?? json['roundIndex'] as num?)?.toInt() ?? 0,
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      isCorrect: json['is_correct'] as bool? ?? json['isCorrect'] as bool? ?? false,
      damageDealt: (json['damage_dealt'] as num? ?? json['damageDealt'] as num?)?.toInt() ?? 0,
      scoreAwarded: (json['score_awarded'] as num? ?? json['scoreAwarded'] as num?)?.toInt() ?? 0,
      opponentDamageDealt: (json['opponent_damage_dealt'] as num? ?? json['opponentDamageDealt'] as num?)?.toInt() ?? 0,
      opponentIsCorrect: json['opponent_is_correct'] as bool? ?? json['opponentIsCorrect'] as bool? ?? false,
      opponentScoreAwarded: (json['opponent_score_awarded'] as num? ?? json['opponentScoreAwarded'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Career stats and competitive rating of a player in PvP
class PvPStats {
  final String userId;
  final String name;
  final int rating;
  final PvPTier tier;
  final int wins;
  final int losses;
  final int draws;
  final int totalMatches;
  final double winRate;
  final int currentStreak;
  final int bestStreak;
  final int totalCoinsWon;
  final String favoriteSubject;

  const PvPStats({
    required this.userId,
    required this.name,
    required this.rating,
    required this.tier,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.totalMatches,
    required this.winRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCoinsWon,
    required this.favoriteSubject,
  });

  factory PvPStats.fromJson(Map<String, dynamic> json) {
    final r = (json['rating'] as num?)?.toInt() ?? 1200;
    return PvPStats(
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Scholar Duelist',
      rating: r,
      tier: json['tier'] != null ? PvPTier.fromString(json['tier'].toString()) : PvPTier.fromRating(r),
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      totalMatches: (json['total_matches'] as num? ?? json['totalMatches'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num? ?? json['winRate'] as num?)?.toDouble() ?? 0.0,
      currentStreak: (json['current_streak'] as num? ?? json['currentStreak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['best_streak'] as num? ?? json['bestStreak'] as num?)?.toInt() ?? 0,
      totalCoinsWon: (json['total_coins_won'] as num? ?? json['totalCoinsWon'] as num?)?.toInt() ?? 0,
      favoriteSubject: json['favorite_subject']?.toString() ?? json['favoriteSubject']?.toString() ?? 'Mathematics',
    );
  }

  PvPStats copyWith({
    String? userId,
    String? name,
    int? rating,
    PvPTier? tier,
    int? wins,
    int? losses,
    int? draws,
    int? totalMatches,
    double? winRate,
    int? currentStreak,
    int? bestStreak,
    int? totalCoinsWon,
    String? favoriteSubject,
  }) {
    return PvPStats(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      tier: tier ?? this.tier,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      totalMatches: totalMatches ?? this.totalMatches,
      winRate: winRate ?? this.winRate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCoinsWon: totalCoinsWon ?? this.totalCoinsWon,
      favoriteSubject: favoriteSubject ?? this.favoriteSubject,
    );
  }
}


/// Pending duel challenge item
class PvPChallengeItem {
  final String id;
  final String challengerId;
  final String challengerName;
  final String? challengedId;
  final String? challengedName;
  final String subject;
  final int stakeCoins;
  final String status;
  final String? sessionId;
  final String createdAt;

  const PvPChallengeItem({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    this.challengedId,
    this.challengedName,
    required this.subject,
    required this.stakeCoins,
    this.status = 'pending',
    this.sessionId,
    required this.createdAt,
  });

  factory PvPChallengeItem.fromJson(Map<String, dynamic> json) {
    return PvPChallengeItem(
      id: json['id']?.toString() ?? '',
      challengerId: json['challengerId']?.toString() ?? json['challenger_id']?.toString() ?? '',
      challengerName: json['challengerName']?.toString() ?? json['challenger_name']?.toString() ?? 'Scholar',
      challengedId: json['challengedId']?.toString() ?? json['challenged_id']?.toString(),
      challengedName: json['challengedName']?.toString() ?? json['challenged_name']?.toString(),
      subject: json['subject']?.toString() ?? 'Mathematics',
      stakeCoins: (json['stakeCoins'] as num? ?? json['stake_coins'] as num?)?.toInt() ?? 50,
      status: json['status']?.toString() ?? 'pending',
      sessionId: json['sessionId']?.toString() ?? json['session_id']?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
    );
  }
}


/// Response returned from submitting a round answer
class PvPRoundResponse {
  final PvPSession? session;
  final PvPRoundResult? roundResult;

  const PvPRoundResponse({
    this.session,
    this.roundResult,
  });
}

