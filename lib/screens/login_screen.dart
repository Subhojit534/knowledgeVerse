import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/player_profile.dart';
import '../services/api_service.dart';
import 'splash_screen.dart';
import 'world_archipelago_screen.dart';

/// 16-Bit RPG Login Screen for existing Hexafalls Explorers.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both your Explorer Name and Password!';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.post(
        '/api/auth/login',
        body: {'name': name, 'password': password},
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final profileData = data['profile'] as Map<String, dynamic>;
        final profile = PlayerProfile.fromJson(profileData);
        await profile.save();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => WorldArchipelagoScreen(profile: profile),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        setState(() {
          _errorMessage = data['error'] as String? ?? 'Invalid credentials. Please check your name & password.';
        });
      }
    } catch (e) {
      debugPrint('❌ [Login Error]: $e');
      setState(() {
        _errorMessage = 'Could not reach backend server. Please verify your connection!';
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E32),
                  border: Border.all(color: const Color(0xFFF2CA50), width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.key_rounded, color: Color(0xFFF2CA50), size: 36),
                          const SizedBox(height: 8),
                          Text(
                            'EXPLORER LOGIN',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 12,
                              color: const Color(0xFFF2CA50),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter your credentials to re-enter Hexafalls',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7,
                              color: const Color(0xFFD0C5AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Box
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF501414),
                          border: Border.all(color: const Color(0xFFFF6B6B), width: 1.5),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.pressStart2p(fontSize: 7.5, color: const Color(0xFFFF6B6B)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Explorer Name Input
                    Text('EXPLORER NAME:', style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8.5),
                      decoration: InputDecoration(
                        hintText: 'e.g. Subhojit',
                        hintStyle: GoogleFonts.pressStart2p(color: Colors.white38, fontSize: 7.5),
                        filled: true,
                        fillColor: const Color(0xFF141424),
                        contentPadding: const EdgeInsets.all(12),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D4635), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password Input
                    Text('PASSWORD:', style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8.5),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: GoogleFonts.pressStart2p(color: Colors.white38, fontSize: 7.5),
                        filled: true,
                        fillColor: const Color(0xFF141424),
                        contentPadding: const EdgeInsets.all(12),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4D4635), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2CA50),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(),
                      ),
                      onPressed: _isSubmitting ? null : _handleLogin,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text('ENTER REALM 🔑', style: GoogleFonts.pressStart2p(fontSize: 9, color: Colors.black)),
                    ),
                    const SizedBox(height: 12),

                    // Back to Splash
                    TextButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      ),
                      child: Text(
                        'BACK TO START',
                        style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
