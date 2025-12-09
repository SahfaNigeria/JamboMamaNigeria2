import 'package:shared_preferences/shared_preferences.dart';

/// Simple helper to work with languages
class LanguageHelper {
  /// Get what language the user selected
  static Future<String> getCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auto_i8ln_locale') ?? 'en';
    } catch (e) {
      return 'en'; // Default to English if error
    }
  }

  /// Get the text in the user's language
  /// If Firebase field looks like: {'en': 'Hello', 'fr': 'Bonjour'}
  /// This returns 'Hello' if user selected English
  static String getTranslatedText(dynamic field, String userLanguage) {
    // If field is empty or null
    if (field == null) return '';

    // If field is a Map (multilingual data)
    if (field is Map) {
      // Try to get user's language
      if (field.containsKey(userLanguage)) {
        return field[userLanguage]?.toString() ?? '';
      }
      // If user's language not available, try English
      if (field.containsKey('en')) {
        return field['en']?.toString() ?? '';
      }
      // If nothing available, return empty
      return '';
    }

    // If it's just plain text (not multilingual), return it as is
    return field.toString();
  }
}
