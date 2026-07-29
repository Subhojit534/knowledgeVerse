import 'package:flutter/material.dart';
import '../../config/asset_paths.dart';
import 'building_data.dart';

/// Central registry providing pre-configured specs for all campus buildings
/// using original high-quality building PNG sprites and level progression.
abstract final class SampleBuildingData {
  /// The Grand Hall — main hub / central landmark (North).
  static const BuildingData grandHall = BuildingData(
    id: 'grand_hall',
    name: 'The Grand Hall',
    icon: Icons.castle,
    sprite: AssetPaths.buildingGrandHall,
    level: 1,
    subject: 'Hub & Headquarters',
    description: 'The majestic center of the Academy. Attend assemblies, receive quests, and consult with Professor Orion.',
    unlocked: true,
    currentXp: 100,
    xpRequired: 300,
    lessonsAvailable: 20,
    themeColor: Color(0xFFCBA6F7),
  );

  /// Library — Theory & Lore (North West).
  static const BuildingData library = BuildingData(
    id: 'library',
    name: 'Library',
    icon: Icons.menu_book,
    sprite: AssetPaths.buildingLibrary,
    level: 1,
    subject: 'Theory & Lore',
    description: 'Explore fundamental data structures, classical CS research papers, and historical computing literature.',
    unlocked: true,
    currentXp: 200,
    xpRequired: 300,
    lessonsAvailable: 12,
    themeColor: Color(0xFFF38BA8),
  );

  /// Astronomy Tower — Physics & Space (North East).
  static const BuildingData astronomyTower = BuildingData(
    id: 'astronomy_tower',
    name: 'Astronomy Tower',
    icon: Icons.star,
    sprite: AssetPaths.buildingAstronomyTower,
    level: 1,
    subject: 'Physics & Space',
    description: 'Study celestial mechanics, physics simulations, vector math and space science.',
    unlocked: true,
    currentXp: 100,
    xpRequired: 300,
    lessonsAvailable: 10,
    themeColor: Color(0xFF89DCEB),
  );

  /// Arena — PvP Battles (West).
  static const BuildingData arena = BuildingData(
    id: 'arena',
    name: 'Arena',
    icon: Icons.sports_mma,
    sprite: AssetPaths.buildingDuelArena,
    level: 1,
    subject: 'PvP Battles',
    description: 'Test your coding speed and problem solving in real-time competitive duels and timed code challenges.',
    unlocked: true,
    currentXp: 100,
    xpRequired: 300,
    lessonsAvailable: 8,
    themeColor: Color(0xFFFAB387),
  );

  /// Potion Lab — Chemistry & Potions (South West).
  static const BuildingData potionLab = BuildingData(
    id: 'potion_lab',
    name: 'Potion Lab',
    icon: Icons.science,
    sprite: AssetPaths.buildingAlchemyLab,
    level: 1,
    subject: 'Chemistry & Potions',
    description: 'Conduct interactive AI logic experiments, state management tests, and potion brewing simulations.',
    unlocked: true,
    currentXp: 0,
    xpRequired: 300,
    lessonsAvailable: 10,
    themeColor: Color(0xFFA6E3A1),
  );

  /// Coding Tower — Programming (South East).
  static const BuildingData codingTower = BuildingData(
    id: 'coding_tower',
    name: 'Coding Tower',
    icon: Icons.computer,
    sprite: AssetPaths.buildingCodingTower,
    level: 1,
    subject: 'Programming',
    description: 'Master programming algorithms, Dart syntax, object-oriented design, and software architecture.',
    unlocked: true,
    currentXp: 200,
    xpRequired: 300,
    lessonsAvailable: 15,
    themeColor: Color(0xFF89B4FA),
  );

  /// History Hall — History & Civics.
  static const BuildingData historyHall = BuildingData(
    id: 'history_hall',
    name: 'History Hall',
    icon: Icons.history_edu,
    sprite: AssetPaths.buildingHistoryHall,
    level: 1,
    subject: 'History & Civics',
    description: 'Explore the history of computing, civilizations, and civic structures through interactive lessons.',
    unlocked: true,
    currentXp: 100,
    xpRequired: 300,
    lessonsAvailable: 9,
    themeColor: Color(0xFFEBA0AC),
  );

  /// List of all pre-configured sample buildings.
  static List<BuildingData> get allBuildings => [
        grandHall,
        library,
        astronomyTower,
        arena,
        potionLab,
        codingTower,
      ];

  // Backward compatibility aliases
  static const BuildingData duelArena = arena;
  static const BuildingData alchemyLab = potionLab;
  static const BuildingData scienceLab = potionLab;
}
