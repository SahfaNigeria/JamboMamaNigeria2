import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _isLoggedInKey = 'session_is_logged_in';
  static const _isHealthProfessionalKey = 'session_is_health_professional';
  static const _profileCompleteKey = 'session_profile_complete';

  static Future<void> saveSession({
    required bool isHealthProfessional,
    required bool profileComplete,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setBool(
      _isHealthProfessionalKey,
      isHealthProfessional,
    );
    await prefs.setBool(_profileCompleteKey, profileComplete);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<bool> isHealthProfessional() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isHealthProfessionalKey) ?? false;
  }

  static Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileCompleteKey) ?? false;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_isHealthProfessionalKey);
    await prefs.remove(_profileCompleteKey);
    await prefs.remove('isHealthProffessional');
  }
}
