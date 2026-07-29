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

/// Full HUD overlay matching the reference image layout:
/// - Top-left: Portrait card + currency stack
/// - Top-right: Movement toggle + Settings button (standardized 64x72 cards)
/// - Right-edge (center): District + Inventory side buttons (standardized 64x72 cards)
/// - Bottom-left: Virtual Joystick (shifted 50px right)
/// - Bottom-right: Bottom navbar (Map, Social, Leaderboard, Shop as 64x72 cards)
/// - Center-top (conditional): Notification banner
/// - Center (conditional): Building action panel
class GameHudWidget extends StatelessWidget {
  final String? notificationMessage;

  const GameHudWidget({
    super.key,
    this.notificationMessage,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = GameState();
    final buildingManager = BuildingManager();
    final fsm = GameStateManager();

    return AnimatedBuilder(
      animation: Listenable.merge([gameState, buildingManager, fsm]),
      builder: (context, child) {
        final activeBuilding = buildingManager.activePanelBuilding;
        final String? currentNotification =
            notificationMessage ?? fsm.activeNotification;

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
                      playerName: 'Arcanist',
                      level: 12,
                      currentXp: 850,
                      maxXp: 1500,
                    ),
                    const SizedBox(height: 10),
                    CurrencyRowWidget(
                      coins: 2450,
                      gems: 340,
                      energy: 120,
                      maxEnergy: 120,
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
