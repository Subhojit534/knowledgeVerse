import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API Configuration service for KnowledgeVerse.
class ApiConfig {
  static const String _defaultFallback = 'http://127.0.0.1:8000';
  static String? _cachedBaseUrl;
  static bool _initialized = false;

  /// Initializes `flutter_dotenv` and configures the centralized base URL.
  static Future<void> init() async {
    if (_initialized) return;

    try {
      await dotenv.load(fileName: '.env');
      final envUrl = dotenv.env['API_BASE_URL']?.trim();

      if (envUrl != null && envUrl.isNotEmpty) {
        _cachedBaseUrl = envUrl.endsWith('/')
            ? envUrl.substring(0, envUrl.length - 1)
            : envUrl;
        debugPrint('✅ [ApiConfig]: Loaded API_BASE_URL from .env: $_cachedBaseUrl');
      } else {
        _handleMissingEnv('API_BASE_URL key is empty or null in .env');
      }
    } catch (e) {
      _handleMissingEnv('Failed to load .env file: $e');
    }

    _initialized = true;
  }

  static void _handleMissingEnv(String reason) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('⚠️ [ApiConfig Warning]: $reason');
    debugPrint('⚠️ Falling back to default URL: $_defaultFallback');
    debugPrint('💡 Make sure a valid .env file exists with API_BASE_URL set.');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _cachedBaseUrl = _defaultFallback;
  }

  /// Returns the current backend base URL configured in `.env`.
  static String get baseUrl {
    String url = _cachedBaseUrl ?? dotenv.env['API_BASE_URL']?.trim() ?? _defaultFallback;
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Utility getter to check if the app is currently pointing to localhost / dev.
  static bool get isLocalDev =>
      baseUrl.contains('127.0.0.1') ||
      baseUrl.contains('localhost') ||
      baseUrl.contains('10.0.2.2') ||
      baseUrl.contains('10.148.');
}
