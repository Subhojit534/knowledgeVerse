import 'package:flutter/material.dart';
import '../../managers/building_manager.dart';
import '../../managers/game_state.dart';
import '../../managers/game_state_manager.dart';
import '../dialogs/building_action_panel.dart';
import '../dialogs/lesson_launcher.dart';
import 'bottom_navbar.dart';
import 'currency_row.dart';
import 'movement_toggle.dart';
import 'notification_banner.dart';
import 'portrait_card.dart';
import 'settings_button.dart';
import 'side_buttons.dart';

import '../../../models/player_profile.dart';

/// Full HUD overlay matching the reference image layout:
/// - Top-left: Portrait card + currency stack
/// - Top-right: Movement toggle + Settings button (standardized 64x72 cards)
/// - Right-edge (center): District + Inventory side buttons (standardized 64x72 cards)
/// - Bottom-left: Virtual Joystick (shifted 50px right)
/// - Bottom-right: Bottom navbar (Map, Social, Leaderboard, Shop as 64x72 cards)
/// - Center-top (conditional): Notification banner
/// - Center (conditional): Building action panel
class GameHudWidget extends StatefulWidget {
  final String? notificationMessage;

  const GameHudWidget({
    super.key,
    this.notificationMessage,
  });

  @override
  State<GameHudWidget> createState() => _GameHudWidgetState();
}

class _GameHudWidgetState extends State<GameHudWidget> {
  PlayerProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = PlayerProfile.current ?? await PlayerProfile.load();
    if (p != null && mounted) {
      setState(() => _profile = p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = GameState();
    final buildingManager = BuildingManager();
    final fsm = GameStateManager();

    return AnimatedBuilder(
      animation: Listenable.merge([gameState, buildingManager, fsm, PlayerProfile.notifier]),
      builder: (context, child) {
        final activeBuilding = buildingManager.activePanelBuilding;
        final String? currentNotification =
            widget.notificationMessage ?? fsm.activeNotification;

        final profile = PlayerProfile.notifier.value ?? PlayerProfile.current ?? _profile ?? const PlayerProfile();
        final displayName = profile.name.isNotEmpty ? profile.name : 'Arcanist';
        final displayLevel = profile.level;
        final displayCurrentLvlXp = profile.currentLevelXp;
        final displayMaxLvlXp = profile.nextLevelXpRequired;
        final displayCoins = profile.coins;
        final displayGems = profile.gems;
        final displayEnergy = profile.energy;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ─── Top-Left: Portrait Card + Currency ───────────────────────
            Positioned(
              top: 12,
              left: 12,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PortraitCardWidget(
                      playerName: displayName,
                      level: displayLevel,
                      currentXp: displayCurrentLvlXp,
                      maxXp: displayMaxLvlXp,
                      profile: profile,
                    ),
                    const SizedBox(height: 10),
                    CurrencyRowWidget(
                      coins: displayCoins,
                      gems: displayGems,
                      energy: displayEnergy,
                      maxEnergy: 100,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Top-Right: Movement Toggle + Settings (Absolute Top-Right Corner) ───
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MovementToggleWidget(
                    currentMode: gameState.movementMode,
                  ),
                  const SizedBox(width: 8),
                  const SettingsButtonWidget(),
                ],
              ),
            ),

            // ─── Right Edge (center): District + Inventory (Standardized 64x72)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: const SideButtonsWidget(),
              ),
            ),

            // ─── Bottom-Right: Bottom Navbar (Standardized 64x72) ──────────
            Positioned(
              bottom: 8,
              right: 8,
              child: const BottomNavbarWidget(),
            ),

            // ─── Notification Banner (center-top) ─────────────────────────
            if (currentNotification != null && currentNotification.isNotEmpty)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: NotificationBannerWidget(
                    message: currentNotification,
                  ),
                ),
              ),

            // ─── Building Action Panel (fullscreen overlay) ────────────────
            if (activeBuilding != null)
              BuildingActionPanel(
                building: activeBuilding,
                onClose: () => buildingManager.closePanel(),
                onLearn: () {
                  buildingManager.closePanel();
                  LessonLauncher.launchBuilding(context, activeBuilding);
                },
              ),
          ],
        );
      },
    );
  }
}
