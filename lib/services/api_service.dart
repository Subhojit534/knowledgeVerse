import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Centralized API HTTP Service for KnowledgeVerse.
///
/// Automatically prepends [ApiConfig.baseUrl] to relative endpoints,
/// manages headers, timeouts, error logging, and standard response processing
/// across all application modules:
/// - Authentication
/// - User Profile
/// - Lessons & AI Quiz Engine
/// - Buildings & World
/// - Progress & XP
/// - Leaderboard
/// - Inventory & Equipment
/// - Arcane Shop
/// - Social & Friends
/// - Guilds & Real-time Chat
class ApiService {
  static const Duration _defaultTimeout = Duration(seconds: 60);

  /// Helper to build full URL from relative path
  static Uri _buildUri(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$cleanPath');
  }

  /// Default headers for JSON requests
  static Map<String, String> _buildHeaders([Map<String, String>? customHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  /// Perform a GET request to the backend
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      debugPrint('🌐 [ApiService GET]: $uri');
      final response = await http
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return response;
    } on TimeoutException {
      debugPrint('❌ [ApiService GET Timeout]: $uri');
      rethrow;
    } catch (e) {
      debugPrint('❌ [ApiService GET Error]: $uri -> $e');
      rethrow;
    }
  }

  /// Perform a POST request to the backend
  static Future<http.Response> post(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      debugPrint('🌐 [ApiService POST]: $uri');
      final encodedBody = body is String ? body : jsonEncode(body);
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: encodedBody,
          )
          .timeout(timeout);
      return response;
    } on TimeoutException {
      debugPrint('❌ [ApiService POST Timeout]: $uri');
      rethrow;
    } catch (e) {
      debugPrint('❌ [ApiService POST Error]: $uri -> $e');
      rethrow;
    }
  }

  /// Perform a PUT request to the backend
  static Future<http.Response> put(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      debugPrint('🌐 [ApiService PUT]: $uri');
      final encodedBody = body is String ? body : jsonEncode(body);
      final response = await http
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: encodedBody,
          )
          .timeout(timeout);
      return response;
    } on TimeoutException {
      debugPrint('❌ [ApiService PUT Timeout]: $uri');
      rethrow;
    } catch (e) {
      debugPrint('❌ [ApiService PUT Error]: $uri -> $e');
      rethrow;
    }
  }

  /// Perform a DELETE request to the backend
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      debugPrint('🌐 [ApiService DELETE]: $uri');
      final response = await http
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return response;
    } on TimeoutException {
      debugPrint('❌ [ApiService DELETE Timeout]: $uri');
      rethrow;
    } catch (e) {
      debugPrint('❌ [ApiService DELETE Error]: $uri -> $e');
      rethrow;
    }
  }

  // ===========================================================================
  // MODULE SPECIFIC ROUTE HELPERS
  // ===========================================================================

  /// Authentication endpoints
  static String authRoute(String subpath) => '/api/auth/$subpath';

  /// User Profile endpoints
  static String profileRoute(String subpath) => '/api/profile/$subpath';

  /// Lessons & Learning endpoints
  static String learningRoute(String subpath) => '/api/learning/$subpath';

  /// Leaderboard endpoints
  static String leaderboardRoute(String subpath) => '/api/leaderboard/$subpath';

  /// Inventory endpoints
  static String inventoryRoute(String subpath) => '/api/inventory/$subpath';

  /// Arcane Shop endpoints
  static String shopRoute(String subpath) => '/api/shop/$subpath';

  /// Social endpoints
  static String socialRoute(String subpath) => '/api/social/$subpath';

  /// Guilds endpoints
  static String guildsRoute(String subpath) => '/api/guilds/$subpath';
}
