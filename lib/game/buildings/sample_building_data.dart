import 'building_data.dart';
import 'curriculum_buildings_catalog.dart';

/// Central registry providing building definitions.
abstract final class SampleBuildingData {
  /// Default Class 10 Math chapter buildings
  static final List<BuildingData> _defaultBuildings =
      CurriculumBuildingsCatalog.getBuildingsFor(subject: 'Mathematics', grade: 'Class 10');

  static BuildingData get grandHall => _defaultBuildings[0];
  static BuildingData get library => _defaultBuildings[1];
  static BuildingData get astronomyTower => _defaultBuildings[2];
  static BuildingData get arena => _defaultBuildings[3];
  static BuildingData get potionLab => _defaultBuildings[4];
  static BuildingData get codingTower => _defaultBuildings[5];

  /// List of all buildings for default startup registry.
  static List<BuildingData> get allBuildings => _defaultBuildings;

  // Backward compatibility aliases
  static BuildingData get duelArena => arena;
  static BuildingData get alchemyLab => potionLab;
  static BuildingData get scienceLab => potionLab;
}
