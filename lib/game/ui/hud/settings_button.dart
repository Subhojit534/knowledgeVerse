import 'package:flutter/material.dart';
import '../../../../screens/settings_screen.dart';

/// Reference-style gear settings button matching _SideIconButton card layout.
/// Displays a 64x72 obsidian card with bronze border, gear icon, and 'Settings' label.
class SettingsButtonWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const SettingsButtonWidget({super.key, this.onTap});

  @override
  State<SettingsButtonWidget> createState() => _SettingsButtonWidgetState();
}

class _SettingsButtonWidgetState extends State<SettingsButtonWidget> {
  bool _isHovered = false;

  void _handleClick() {
    widget.onTap?.call();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleClick,
        child: AnimatedScale(
          scale: _isHovered ? 1.06 : 1.0,
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
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.settings_rounded,
                    color: Color(0xFFF9E2AF), size: 28),
                SizedBox(height: 4),
                Text(
                  'Settings',
                  style: TextStyle(
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
