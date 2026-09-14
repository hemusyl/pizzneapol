import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Service managing persistent customer authentication session in local storage.
class SessionService {
  SessionService._();

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  /// Saves Sanctum token and customer profile to local preferences
  static Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    } catch (_) {
      // Graceful fallback if platform channels are unavailable
    }
  }

  /// Retrieves stored authorization token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyToken);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (_) {}
    return null;
  }

  /// Retrieves stored authenticated user model
  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_keyUser);
      if (userString != null && userString.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(userString);
        return UserModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  /// Clears stored token and profile on logout
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUser);
    } catch (_) {}
  }
}
