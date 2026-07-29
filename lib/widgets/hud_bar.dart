import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 16-Bit RPG HUD Bar Widget.
/// Renders top stats (Level, XP, Coins, Gems, Energy) with chiseled obsidian containers,
/// double-gold pixel borders, Press Start 2P pixel typography, and stepped progress bars.
class HudBar extends StatelessWidget {
  const HudBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Left: Player Level + XP Stepped Progress
            _OrnatePixelBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF28283D),
                      border: Border.all(color: const Color(0xFFF2CA50), width: 2),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFF2CA50),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'LVL 14',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 9,
                              color: const Color(0xFFF2CA50),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '840/1200 XP',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7,
                              color: const Color(0xFFD0C5AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Stepped Pixel Progress Bar
                      Container(
                        width: 110,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E32),
                          border: Border.all(
                              color: const Color(0xFF4D4635), width: 1),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.7,
                          child: Container(
                            color: const Color(0xFF82C0A0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Right: Resource Badges (Coins, Gems, Energy)
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _PixelResourceBadge(
                      icon: Icons.monetization_on_rounded,
                      value: '1,240',
                      iconColor: Color(0xFFF2CA50),
                      textColor: Color(0xFFF2CA50),
                    ),
                    SizedBox(width: 6),
                    _PixelResourceBadge(
                      icon: Icons.diamond_rounded,
                      value: '24',
                      iconColor: Color(0xFFDEB7FF),
                      textColor: Color(0xFFDEB7FF),
                    ),
                    SizedBox(width: 6),
                    _PixelResourceBadge(
                      icon: Icons.bolt_rounded,
                      value: '100/100',
                      iconColor: Color(0xFF9DDCBB),
                      textColor: Color(0xFF9DDCBB),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelResourceBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color iconColor;
  final Color textColor;

  const _PixelResourceBadge({
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return _OrnatePixelBox(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnatePixelBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _OrnatePixelBox({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32).withValues(alpha: 0.95),
        border: Border.all(color: const Color(0xFFF2CA50), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
