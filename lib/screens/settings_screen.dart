import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_profile.dart';
import '../services/theme_music_service.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

/// 16-Bit RPG System Options Screen.
/// Features chiseled obsidian option tablets, retro pixel toggles,
/// Press Start 2P typography, scanlines shader control, and double-gold pixel frames.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sfxEnabled = true;
  late bool _musicEnabled;
  bool _scanlinesEnabled = true;
  String _graphicsMode = '16-BIT RETRO';

  @override
  void initState() {
    super.initState();
    _musicEnabled = ThemeMusicService.musicEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111125),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Night Castle Background Overlay
          Opacity(
            opacity: 0.35,
            child: Image.asset(
              'assets/images/loading_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [Color(0xFF1E1E32), Color(0xFF0C0C1F)],
                  ),
                ),
              ),
            ),
          ),

          // Scanlines Shader Overlay (if enabled)
          if (_scanlinesEnabled)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x1F000000)],
                      stops: [0.5, 0.5],
                      tileMode: TileMode.repeated,
                    ),
                  ),
                ),
              ),
            ),

          // Main Layout
          SafeArea(
            child: Column(
              children: [
                // Header Bar with Back Button
                _buildHeader(),

                // Scrollable Settings Cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            // Audio Options Section
                            _OrnateFrameCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AUDIO CONTROLS',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 10,
                                      color: const Color(0xFFF2CA50),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Sound Effects Toggle
                                  _PixelToggleOption(
                                    icon: Icons.volume_up_rounded,
                                    label: 'SOUND EFFECTS (SFX)',
                                    value: _sfxEnabled,
                                    onChanged: (val) =>
                                        setState(() => _sfxEnabled = val),
                                  ),
                                  const SizedBox(height: 10),

                                  // Theme Music Toggle
                                  _PixelToggleOption(
                                    icon: Icons.music_note_rounded,
                                    label: 'BACKGROUND MUSIC',
                                    value: _musicEnabled,
                                    onChanged: (val) {
                                      setState(() => _musicEnabled = val);
                                      ThemeMusicService.musicEnabled = val;
                                      if (val) {
                                        ThemeMusicService.instance.start();
                                      } else {
                                        ThemeMusicService.instance
                                            .fadeOutAndStop();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Graphics Options Section
                            _OrnateFrameCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GRAPHICS & VISUALS',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 10,
                                      color: const Color(0xFFF2CA50),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Scanline Overlay Toggle
                                  _PixelToggleOption(
                                    icon: Icons.tv_rounded,
                                    label: 'CRT SCANLINES OVERLAY',
                                    value: _scanlinesEnabled,
                                    onChanged: (val) =>
                                        setState(() => _scanlinesEnabled = val),
                                  ),
                                  const SizedBox(height: 14),

                                  // Graphics Quality Selector
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'TEXTURE STYLE',
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 8,
                                          color: const Color(0xFFD0C5AF),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _graphicsMode =
                                                _graphicsMode == '16-BIT RETRO'
                                                    ? 'HIGH RES'
                                                    : '16-BIT RETRO';
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF065F46),
                                            border: Border.all(
                                                color: const Color(0xFFF2CA50),
                                                width: 1.5),
                                          ),
                                          child: Text(
                                            _graphicsMode,
                                            style: GoogleFonts.pressStart2p(
                                              fontSize: 8,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Reset / Account Section
                            _OrnateFrameCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SYSTEM & DATA',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 10,
                                      color: const Color(0xFFFFB4AB),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Resetting data will clear saved progress and local preferences.',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      color: const Color(0xFFD0C5AF),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () async {
                                      await PlayerProfile.logout();
                                      if (!context.mounted) return;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                                        (route) => false,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF501414),
                                        border: Border.all(
                                            color: const Color(0xFFFF6B6B),
                                            width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black,
                                              offset: Offset(2, 2)),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'RESET SAVE DATA ⚠️',
                                          style: GoogleFonts.pressStart2p(
                                            fontSize: 9,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () async {
                                      await PlayerProfile.logout();
                                      if (!context.mounted) return;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                                        (route) => false,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E1E32),
                                        border: Border.all(color: const Color(0xFFF2CA50), width: 2),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'LOGOUT EXPLORER 🚪',
                                          style: GoogleFonts.pressStart2p(
                                            fontSize: 9,
                                            color: const Color(0xFFF2CA50),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Back Button to return to game / previous screen
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E32),
                border: Border.all(color: const Color(0xFFF2CA50), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFF2CA50),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.settings_rounded,
              color: Color(0xFFF2CA50), size: 24),
          const SizedBox(width: 10),
          Text(
            'SYSTEM OPTIONS',
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: const Color(0xFFF2CA50),
              letterSpacing: 2.0,
              shadows: const [
                Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PixelToggleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PixelToggleOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111125),
        border: Border.all(color: const Color(0xFF333348), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF2CA50), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: const Color(0xFFD0C5AF),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF065F46) : const Color(0xFF28283D),
                border: Border.all(
                  color: value ? const Color(0xFF4ADE80) : const Color(0xFF4D4635),
                  width: 1.5,
                ),
              ),
              child: Text(
                value ? 'ON' : 'OFF',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: value ? const Color(0xFF4ADE80) : const Color(0xFFFFB4AB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnateFrameCard extends StatelessWidget {
  final Widget child;

  const _OrnateFrameCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E32).withValues(alpha: 0.95),
            border: Border.all(color: const Color(0xFFF2CA50), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF735C00),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
        // 4 Corner Purple Jeweled Accents
        const _CornerGem(top: -4, left: -4),
        const _CornerGem(top: -4, right: -4),
        const _CornerGem(bottom: -4, left: -4),
        const _CornerGem(bottom: -4, right: -4),
      ],
    );
  }
}

class _CornerGem extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _CornerGem({
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFF6B13AF),
          border: Border.all(
            color: const Color(0xFFF2CA50),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
