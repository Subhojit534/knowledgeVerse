import 'package:flutter/material.dart';
import '../../../config/asset_paths.dart';
import '../../../../screens/profile_screen.dart';
import '../../../models/player_profile.dart';

/// Player portrait card widget — top-left corner of the main game screen.
/// Shows avatar, level badge, and XP progress bar (without player name text as requested).
/// Clicking anywhere on the card navigates directly to ProfileScreen.
class PortraitCardWidget extends StatelessWidget {
  final String playerName;
  final int level;
  final int currentXp;
  final int maxXp;
  final PlayerProfile? profile;

  const PortraitCardWidget({
    super.key,
    this.playerName = '',
    this.level = 1,
    this.currentXp = 150,
    this.maxXp = 200,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final double xpRatio = maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0.5;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen(profile: profile)),
        );
      },
      child: Container(
        width: 175,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xE0122040),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF2CA50), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar portrait with gold border
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF2CA50), width: 2),
                color: const Color(0xFF0D1B2A),
                image: const DecorationImage(
                  image: AssetImage(
                    AssetPaths.playerArcanistPortrait,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Level & XP Bar (No Player Name Text)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E32),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFF2CA50), width: 1),
                    ),
                    child: Text(
                      'LVL $level',
                      style: const TextStyle(
                        color: Color(0xFFF2CA50),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // XP Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: const Color(0xFF1A1A2E),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: xpRatio,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF9B59D4), Color(0xFFCBA6F7)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$currentXp / $maxXp XP',
                    style: const TextStyle(
                      color: Color(0xFFCBA6F7),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
