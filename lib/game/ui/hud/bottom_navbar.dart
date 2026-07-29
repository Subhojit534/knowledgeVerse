import 'package:flutter/material.dart';
import '../../../../screens/world_archipelago_screen.dart';
import '../../../../screens/social_screen.dart';
import '../../../../screens/leaderboard_screen.dart';
import '../../../../screens/shop_screen.dart';
import '../../../services/theme_music_service.dart';

/// Single unified bottom navigation bar container grouping Map, Social, Rank, and Shop together.
class BottomNavbarWidget extends StatefulWidget {
  const BottomNavbarWidget({super.key});

  @override
  State<BottomNavbarWidget> createState() => _BottomNavbarWidgetState();
}

class _BottomNavbarWidgetState extends State<BottomNavbarWidget> {
  int _selectedIndex = 0;
  int _hoveredIndex = -1;

  static const List<_NavItem> _items = [
    _NavItem(
        label: 'Map',
        icon: Icons.map_rounded,
        color: Color(0xFFF9E2AF)),
    _NavItem(
        label: 'Social',
        icon: Icons.people_alt_rounded,
        color: Color(0xFFA6E3A1)),
    _NavItem(
        label: 'Rank',
        icon: Icons.emoji_events_rounded,
        color: Color(0xFFF9E2AF)),
    _NavItem(
        label: 'Shop',
        icon: Icons.storefront_rounded,
        color: Color(0xFFFAB387)),
  ];

  void _handleItemTap(int index) async {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // Map screen -> SILENT
      ThemeMusicService.instance.stop();
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorldArchipelagoScreen()),
      );
      if (ThemeMusicService.musicEnabled) {
        ThemeMusicService.instance.start();
      }
    } else if (index == 1) {
      // Social screen -> PLAY MUSIC
      if (ThemeMusicService.musicEnabled) {
        ThemeMusicService.instance.start();
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SocialScreen()),
      );
    } else if (index == 2) {
      // Rank screen -> PLAY MUSIC
      if (ThemeMusicService.musicEnabled) {
        ThemeMusicService.instance.start();
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
      );
    } else if (index == 3) {
      // Shop screen -> PLAY MUSIC
      if (ThemeMusicService.musicEnabled) {
        ThemeMusicService.instance.start();
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShopScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xDD122040),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6B5A3E), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final bool isSelected = _selectedIndex == i;
          final bool isHovered = _hoveredIndex == i;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoveredIndex = i),
              onExit: (_) => setState(() => _hoveredIndex = -1),
              child: GestureDetector(
                onTap: () => _handleItemTap(i),
                child: AnimatedScale(
                  scale: isHovered ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    width: 58,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E3A5A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF6B5A3E), width: 1)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: item.color, size: 24),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? item.color : Colors.white70,
                            fontSize: 9.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final Color color;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.color,
  });
}
