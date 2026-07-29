import 'package:flutter/material.dart';
import '../../managers/game_state.dart';

/// Reference-style movement mode toggle button matching _SideIconButton card layout.
/// Displays a 64x72 obsidian card with bronze border, mode icon, and 'Joystick'/'Tap' label.
class MovementToggleWidget extends StatefulWidget {
  final MovementMode currentMode;
  final VoidCallback? onToggle;

  const MovementToggleWidget({
    super.key,
    required this.currentMode,
    this.onToggle,
  });

  @override
  State<MovementToggleWidget> createState() => _MovementToggleWidgetState();
}

class _MovementToggleWidgetState extends State<MovementToggleWidget> {
  bool _isHovered = false;

  void _handleToggle() {
    if (widget.onToggle != null) {
      widget.onToggle!();
    } else {
      GameState().toggleMovementMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isJoystick = widget.currentMode == MovementMode.joystick;
    final String modeLabel = isJoystick ? 'Joystick' : 'Tap';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleToggle,
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
              children: [
                Icon(
                  isJoystick ? Icons.gamepad_rounded : Icons.touch_app_rounded,
                  color: const Color(0xFF89B4FA),
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  modeLabel,
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
