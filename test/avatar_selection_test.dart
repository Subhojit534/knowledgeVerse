import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledgeverse/config/asset_paths.dart';
import 'package:knowledgeverse/config/game_assets.dart';
import 'package:knowledgeverse/game/player/player_animation_controller.dart';
import 'package:knowledgeverse/game/player/player_animation_state.dart';
import 'package:knowledgeverse/models/player_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Avatar Selection & Profile Tests', () {
    test('PlayerProfile stores and serializes avatarIndex', () {
      const maleProfile = PlayerProfile(
        name: 'Aiden',
        avatarIndex: 0,
      );
      expect(maleProfile.avatarIndex, equals(0));
      expect(maleProfile.toJson()['avatar_index'], equals(0));

      final jsonMale = maleProfile.toJson();
      final restoredMale = PlayerProfile.fromJson(jsonMale);
      expect(restoredMale.avatarIndex, equals(0));

      const femaleProfile = PlayerProfile(
        name: 'Lyra',
        avatarIndex: 1,
      );
      expect(femaleProfile.avatarIndex, equals(1));
      expect(femaleProfile.toJson()['avatar_index'], equals(1));

      final jsonFemale = femaleProfile.toJson();
      final restoredFemale = PlayerProfile.fromJson(jsonFemale);
      expect(restoredFemale.avatarIndex, equals(1));
    });

    test('AssetPaths returns correct avatar image paths for avatars', () {
      expect(AssetPaths.getAvatarPortrait(0), equals('assets/images/avatar_male.jpg'));
      expect(AssetPaths.getAvatarPortrait(1), equals('assets/images/avatar_female.jpg'));
    });

    test('PlayerAssets has correct frame counts for male and female assets', () {
      expect(PlayerAssets.maleIdle.length, equals(10));
      expect(PlayerAssets.maleIdleLeft.length, equals(10));
      expect(PlayerAssets.maleWalk.length, equals(10));
      expect(PlayerAssets.maleWalkLeft.length, equals(10));

      expect(PlayerAssets.femaleIdle.length, equals(10));
      expect(PlayerAssets.femaleIdleRight.length, equals(10));
      expect(PlayerAssets.femaleWalk.length, equals(24));
      expect(PlayerAssets.femaleWalkRight.length, equals(24));
    });

    test('PlayerAnimationController updates horizontalFacing and state on joystick velocity', () {
      final maleController = PlayerAnimationController(avatarIndex: 0);
      expect(maleController.avatarIndex, equals(0));
      expect(maleController.horizontalFacing, equals(PlayerFacing.right));
      expect(maleController.currentState, equals(PlayerAnimationState.idle));

      // Move left with joystick
      maleController.update(
        velocity: Vector2(-150.0, 0.0),
        dt: 0.016,
      );
      expect(maleController.currentState, equals(PlayerAnimationState.walk));
      expect(maleController.horizontalFacing, equals(PlayerFacing.left));

      // Move right with joystick
      maleController.update(
        velocity: Vector2(150.0, 0.0),
        dt: 0.016,
      );
      expect(maleController.currentState, equals(PlayerAnimationState.walk));
      expect(maleController.horizontalFacing, equals(PlayerFacing.right));

      // Stop moving (idle)
      maleController.update(
        velocity: Vector2.zero(),
        dt: 0.016,
      );
      expect(maleController.currentState, equals(PlayerAnimationState.idle));
      expect(maleController.horizontalFacing, equals(PlayerFacing.right)); // preserves last facing

      // Female controller
      final femaleController = PlayerAnimationController(avatarIndex: 1);
      expect(femaleController.avatarIndex, equals(1));
      expect(femaleController.horizontalFacing, equals(PlayerFacing.left));

      // Move right
      femaleController.update(
        velocity: Vector2(120.0, 0.0),
        dt: 0.016,
      );
      expect(femaleController.currentState, equals(PlayerAnimationState.walk));
      expect(femaleController.horizontalFacing, equals(PlayerFacing.right));

      // Move up (vertical) -> preserves horizontal facing
      femaleController.update(
        velocity: Vector2(0.0, -120.0),
        dt: 0.016,
      );
      expect(femaleController.currentState, equals(PlayerAnimationState.walk));
      expect(femaleController.horizontalFacing, equals(PlayerFacing.right));
    });
  });
}
