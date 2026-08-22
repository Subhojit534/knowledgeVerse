import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Interactive button component floating above a building when the player is nearby.
/// Cleanly shows 'ENTER' without appending the full building name.
class InteractionButtonComponent extends PositionComponent with TapCallbacks {
  final String buildingName;
  final VoidCallback onPressed;
  bool isVisible = false;

  InteractionButtonComponent({
    required this.buildingName,
    required this.onPressed,
  }) : super(
          size: Vector2(90.0, 30.0),
          anchor: Anchor.center,
          priority: 20,
        );

  final Paint _btnBgPaint = Paint()
    ..color = const Color(0xFFF2CA50)
    ..style = PaintingStyle.fill;

  final Paint _btnBorderPaint = Paint()
    ..color = const Color(0xFF1E1E2E)
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  @override
  void onTapDown(TapDownEvent event) {
    if (isVisible) {
      onPressed();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;
    super.render(canvas);

    final RRect rrect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(15.0),
    );

    // Draw pill-shaped button background and border
    canvas.drawRRect(rrect, _btnBgPaint);
    canvas.drawRRect(rrect, _btnBorderPaint);

    // Draw button text label ('ENTER')
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: 'ENTER',
        style: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w900,
          color: Color(0xFF181825),
          letterSpacing: 1.0,
        ),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
}
