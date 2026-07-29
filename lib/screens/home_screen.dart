import 'package:flutter/material.dart';
import 'world_screen.dart';

/// Main Container Screen hosting the 2D Game World Viewport.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111125),
      body: WorldScreen(),
    );
  }
}
