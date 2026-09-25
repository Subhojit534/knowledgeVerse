import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../config/game_assets.dart';
import '../managers/asset_manager.dart';
import 'player_animation_state.dart';

/// Facing directions for the player character.
enum PlayerFacing { up, down, left, right }

/// Reusable animation controller managing directional player sprite sheet animations
/// for both Avatar 0 (Male Hero), Avatar 1 (Female Sorceress), and legacy Arcanist,
/// with 0° rotation guaranteed at all times.
class PlayerAnimationController {
  final Map<String, SpriteAnimationTicker> _animationTickers = {};

  int avatarIndex;

  /// Current active animation state (idle, walk, interact).
  PlayerAnimationState currentState = PlayerAnimationState.idle;

  /// Current facing direction (up, down, left, right).
  PlayerFacing currentFacing = PlayerFacing.down;

  /// Horizontal facing direction for 2D side-scrolling sprite sheets.
  PlayerFacing horizontalFacing = PlayerFacing.right;

  /// Velocity threshold to trigger walking state.
  final double movementThreshold;

  PlayerAnimationController({
    this.avatarIndex = 0,
    this.movementThreshold = 5.0,
  }) {
    horizontalFacing = avatarIndex == 1 ? PlayerFacing.left : PlayerFacing.right;
  }

  /// Loads directional player animations from game-assets pipeline based on avatarIndex.
  Future<void> load() async {
    _animationTickers.clear();
    final assetManager = GameAssetManager();

    // Helper to load and build sprite sequence animation
    Future<SpriteAnimationTicker?> buildTicker(List<String> framePaths, double stepTime) async {
      for (final path in framePaths) {
        if (!assetManager.images.containsKey(path)) {
          try {
            await assetManager.images.load(path);
          } catch (_) {}
        }
      }
      final anim = assetManager.buildSequenceAnimation(
        framePaths: framePaths,
        stepTime: stepTime,
      );
      return anim?.createTicker();
    }

    if (avatarIndex == 0) {
      // ── AVATAR 0: MALE HERO (from male_hero_free) ───────────────────────────
      final idleRight = await buildTicker(PlayerAssets.maleIdle, 0.12);
      final idleLeft = await buildTicker(PlayerAssets.maleIdleLeft, 0.12);
      final walkRight = await buildTicker(PlayerAssets.maleWalk, 0.08);
      final walkLeft = await buildTicker(PlayerAssets.maleWalkLeft, 0.08);

      if (idleRight != null) _animationTickers['idle_right'] = idleRight;
      if (idleLeft != null) _animationTickers['idle_left'] = idleLeft;
      if (walkRight != null) _animationTickers['walk_right'] = walkRight;
      if (walkLeft != null) _animationTickers['walk_left'] = walkLeft;

      // Directional fallbacks
      if (idleRight != null) _animationTickers['idle_front'] = idleRight;
      if (idleRight != null) _animationTickers['idle_back'] = idleRight;
      if (walkRight != null) _animationTickers['walk_front'] = walkRight;
      if (walkRight != null) _animationTickers['walk_back'] = walkRight;
    } else if (avatarIndex == 1) {
      // ── AVATAR 1: FEMALE SORCERESS (from sample(idle&walk)) ──────────────────
      final idleLeft = await buildTicker(PlayerAssets.femaleIdle, 0.12);
      final idleRight = await buildTicker(PlayerAssets.femaleIdleRight, 0.12);
      final walkLeft = await buildTicker(PlayerAssets.femaleWalk, 0.045);
      final walkRight = await buildTicker(PlayerAssets.femaleWalkRight, 0.045);

      if (idleLeft != null) _animationTickers['idle_left'] = idleLeft;
      if (idleRight != null) _animationTickers['idle_right'] = idleRight;
      if (walkLeft != null) _animationTickers['walk_left'] = walkLeft;
      if (walkRight != null) _animationTickers['walk_right'] = walkRight;

      // Directional fallbacks
      if (idleLeft != null) _animationTickers['idle_front'] = idleLeft;
      if (idleLeft != null) _animationTickers['idle_back'] = idleLeft;
      if (walkLeft != null) _animationTickers['walk_front'] = walkLeft;
      if (walkLeft != null) _animationTickers['walk_back'] = walkLeft;
    } else {
      // ── LEGACY FALLBACK: ARCANIST ──────────────────────────────────────────
      final idleFrontTicker = await buildTicker([
        PlayerAssets.idleArcanistIdleFront01,
        PlayerAssets.idleArcanistIdleFront02,
        PlayerAssets.idleArcanistIdleFront03,
      ], 0.20);
      if (idleFrontTicker != null) _animationTickers['idle_front'] = idleFrontTicker;

      final idleBackTicker = await buildTicker([
        PlayerAssets.idleArcanistIdleBack01,
        PlayerAssets.idleArcanistIdleBack02,
      ], 0.25);
      if (idleBackTicker != null) _animationTickers['idle_back'] = idleBackTicker;

      final walkBackTicker = await buildTicker([
        PlayerAssets.walkArcanistWalkBack,
        PlayerAssets.idleArcanistIdleBack01,
        PlayerAssets.walkArcanistWalkBack,
        PlayerAssets.idleArcanistIdleBack02,
      ], 0.15);
      if (walkBackTicker != null) _animationTickers['walk_back'] = walkBackTicker;

      final walkFrontTicker = await buildTicker([
        PlayerAssets.idleArcanistIdleFront01,
        PlayerAssets.idleArcanistIdleFront02,
        PlayerAssets.idleArcanistIdleFront03,
      ], 0.14);
      if (walkFrontTicker != null) _animationTickers['walk_front'] = walkFrontTicker;

      final walkLeftTicker = await buildTicker([
        PlayerAssets.walkArcanistWalkLeft01,
        PlayerAssets.walkArcanistWalkLeft02,
      ], 0.14);
      if (walkLeftTicker != null) _animationTickers['walk_left'] = walkLeftTicker;

      final walkRightTicker = await buildTicker([
        PlayerAssets.walkArcanistWalkRight01,
        PlayerAssets.walkArcanistWalkRight02,
      ], 0.14);
      if (walkRightTicker != null) _animationTickers['walk_right'] = walkRightTicker;
    }
  }

  /// Automatically updates facing direction and active animation ticker based on movement velocity.
  void update({
    required Vector2 velocity,
    required double dt,
    double baseSpeed = 160.0,
  }) {
    final double speed = velocity.length;

    if (speed > movementThreshold) {
      currentState = PlayerAnimationState.walk;

      final double dx = velocity.x;
      final double dy = velocity.y;

      if (dx.abs() > 3.0) {
        horizontalFacing = dx < 0 ? PlayerFacing.left : PlayerFacing.right;
      }

      if (dy.abs() > dx.abs()) {
        currentFacing = dy < 0 ? PlayerFacing.up : PlayerFacing.down;
      } else {
        currentFacing = dx < 0 ? PlayerFacing.left : PlayerFacing.right;
      }
    } else if (currentState != PlayerAnimationState.interact) {
      currentState = PlayerAnimationState.idle;
    }

    final String activeKey = _getActiveAnimationKey();

    double speedFactor = 1.0;
    if (currentState == PlayerAnimationState.walk) {
      speedFactor = (speed / baseSpeed).clamp(0.5, 1.8);
    }

    _animationTickers[activeKey]?.update(dt * speedFactor);
  }

  String _getActiveAnimationKey() {
    final bool isLeft = horizontalFacing == PlayerFacing.left;

    if (avatarIndex <= 1) {
      if (currentState == PlayerAnimationState.walk) {
        return isLeft ? 'walk_left' : 'walk_right';
      } else {
        return isLeft ? 'idle_left' : 'idle_right';
      }
    }

    // Default Arcanist 4-way
    if (currentState == PlayerAnimationState.walk) {
      switch (currentFacing) {
        case PlayerFacing.up:
          return 'walk_back';
        case PlayerFacing.down:
          return 'walk_front';
        case PlayerFacing.left:
          return 'walk_left';
        case PlayerFacing.right:
          return 'walk_right';
      }
    } else {
      return currentFacing == PlayerFacing.up ? 'idle_back' : 'idle_front';
    }
  }

  void triggerInteraction() {
    currentState = PlayerAnimationState.interact;
    Future.delayed(const Duration(milliseconds: 500), () {
      currentState = PlayerAnimationState.idle;
    });
  }

  Sprite? getCurrentSprite() {
    final String activeKey = _getActiveAnimationKey();
    final sprite = _animationTickers[activeKey]?.getSprite();
    if (sprite != null) return sprite;

    final fallbackKey = (avatarIndex == 1) ? 'idle_left' : 'idle_right';
    return _animationTickers[fallbackKey]?.getSprite() ??
        _animationTickers['idle_front']?.getSprite();
  }

  bool render(Canvas canvas, {required Vector2 size}) {
    final sprite = getCurrentSprite();
    if (sprite != null) {
      final double srcW = sprite.srcSize.x;
      final double srcH = sprite.srcSize.y;
      if (srcW > 0 && srcH > 0) {
        // Keep pixel-perfect aspect ratio anchored to bottom-center (feet at bottom)
        final double drawH = size.y * (srcH / 48.0);
        final double drawW = size.x * (srcW / 48.0);
        final double offsetX = (size.x - drawW) / 2;
        final double offsetY = size.y - drawH;
        sprite.render(
          canvas,
          position: Vector2(offsetX, offsetY),
          size: Vector2(drawW, drawH),
        );
      } else {
        sprite.render(canvas, size: size);
      }
      return true;
    }
    return false;
  }
}
