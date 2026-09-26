import 'package:flutter/material.dart';

/// Reusable Data Model representing building specifications, educational subject,
/// level progression, and available lesson parameters.
class BuildingData {
  /// Unique building identifier.
  final String id;

  /// Display name of the building.
  final String name;

  /// Icon visual representation.
  final IconData icon;

  /// Sprite image asset path (original high-quality building sprite).
  final String sprite;

  /// Current building level (Level 1, Level 2, Level 3).
  final int level;

  /// Educational subject area (e.g. Computer Science, Literature, Science).
  final String subject;

  /// Detailed building description.
  final String description;

  /// Whether building is unlocked for player interaction.
  final bool unlocked;

  /// Current accumulated experience points.
  final int currentXp;

  /// Experience points required to level up (defaults to level * 300).
  final int? _xpRequired;

  int get xpRequired {
    final req = _xpRequired;
    return (req != null && req > 0) ? req : (level * 300);
  }

  /// Number of interactive lessons available inside building.
  final int lessonsAvailable;

  /// Primary theme color for UI badges and card borders.
  final Color themeColor;

  /// Currently attuned topic and subtopic UUIDs from the Red Spell Book
  final String? activeTopicId;
  final String? activeSubtopicId;
  final String? activeTopicName;
  final String? activeSubtopicName;

  const BuildingData({
    required this.id,
    required this.name,
    required this.icon,
    required this.sprite,
    required this.level,
    required this.subject,
    required this.description,
    required this.unlocked,
    this.currentXp = 0,
    int? xpRequired,
    required this.lessonsAvailable,
    this.themeColor = const Color(0xFF89B4FA),
    this.activeTopicId,
    this.activeSubtopicId,
    this.activeTopicName,
    this.activeSubtopicName,
  }) : _xpRequired = xpRequired;

  /// Calculates XP progress ratio [0.0 to 1.0].
  double get progressRatio => xpRequired > 0 ? (currentXp / xpRequired).clamp(0.0, 1.0) : 0.0;

  /// Whether building can be upgraded to next level.
  bool get canUpgrade => level < 3 && currentXp >= xpRequired;

  BuildingData copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? sprite,
    int? level,
    String? subject,
    String? description,
    bool? unlocked,
    int? currentXp,
    int? xpRequired,
    int? lessonsAvailable,
    Color? themeColor,
    String? activeTopicId,
    String? activeSubtopicId,
    String? activeTopicName,
    String? activeSubtopicName,
  }) {
    return BuildingData(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sprite: sprite ?? this.sprite,
      level: level ?? this.level,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      unlocked: unlocked ?? this.unlocked,
      currentXp: currentXp ?? this.currentXp,
      xpRequired: xpRequired ?? _xpRequired,
      lessonsAvailable: lessonsAvailable ?? this.lessonsAvailable,
      themeColor: themeColor ?? this.themeColor,
      activeTopicId: activeTopicId ?? this.activeTopicId,
      activeSubtopicId: activeSubtopicId ?? this.activeSubtopicId,
      activeTopicName: activeTopicName ?? this.activeTopicName,
      activeSubtopicName: activeSubtopicName ?? this.activeSubtopicName,
    );
  }
}
