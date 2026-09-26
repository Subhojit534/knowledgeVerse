import 'package:flutter/material.dart';
import '../../../../screens/inventory_screen.dart';
import '../../../../screens/map_list_screen.dart';
import '../../../services/theme_music_service.dart';
import '../dialogs/ai_chatbot_dialog.dart';

/// Reference-style stacked side buttons — District, Inventory, and AI Tutor on right edge.
class SideButtonsWidget extends StatefulWidget {
  const SideButtonsWidget({super.key});

  @override
  State<SideButtonsWidget> createState() => _SideButtonsWidgetState();
}

class _SideButtonsWidgetState extends State<SideButtonsWidget> {
  bool _districtHovered = false;
  bool _inventoryHovered = false;
  bool _aiTutorHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // District Button -> plays background music
        _SideIconButton(
          label: 'District',
          icon: Icons.map_rounded,
          color: const Color(0xFFF9E2AF),
          isHovered: _districtHovered,
          onHoverChange: (v) => setState(() => _districtHovered = v),
          onTap: () {
            if (ThemeMusicService.musicEnabled) {
              ThemeMusicService.instance.start();
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapListScreen()),
            );
          },
        ),
        const SizedBox(height: 8),

        // Inventory Button -> plays background music
        _SideIconButton(
          label: 'Inventory',
          icon: Icons.inventory_2,
          color: const Color(0xFFFAB387),
          isHovered: _inventoryHovered,
          onHoverChange: (v) => setState(() => _inventoryHovered = v),
          onTap: () {
            if (ThemeMusicService.musicEnabled) {
              ThemeMusicService.instance.start();
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryScreen()),
            );
          },
        ),
        const SizedBox(height: 8),

        // AI Tutor Button -> Opens Archmage Aetherius Groq Chatbot
        _SideIconButton(
          label: 'AI Tutor',
          icon: Icons.auto_awesome,
          color: const Color(0xFFCBA6F7),
          isHovered: _aiTutorHovered,
          onHoverChange: (v) => setState(() => _aiTutorHovered = v),
          onTap: () {
            AiChatbotDialog.show(context);
          },
        ),
      ],
    );
  }
}

class _SideIconButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isHovered;
  final ValueChanged<bool> onHoverChange;
  final VoidCallback onTap;

  const _SideIconButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isHovered,
    required this.onHoverChange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isHovered ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 64,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xDD122040),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6B5A3E), width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
