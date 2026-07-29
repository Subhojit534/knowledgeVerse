import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/academy_game.dart';
import '../game/ui/hud/game_hud.dart';
import '../services/theme_music_service.dart';

/// Primary World Screen hosting the 2D floating Academy Flame Game
/// with player movement, camera controls, building interactions, HUD overlays,
/// and background theme music playback active ONLY on the main game screen.
class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ThemeMusicService.musicEnabled) {
        ThemeMusicService.instance.start();
      }
    });
  }

  @override
  void dispose() {
    ThemeMusicService.instance.fadeOutAndStop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: GameWidget<AcademyGame>.controlled(
        gameFactory: AcademyGame.new,
        overlayBuilderMap: {
          'HUD': (context, game) => const GameHudWidget(),
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}
