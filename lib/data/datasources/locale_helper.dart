import 'dart:io';

class LocaleHelper {
  /// Returns the device language code (e.g. "pt", "en", "ja", "es")
  static String get languageCode {
    final locale = Platform.localeName; // e.g. "pt_BR", "en_US", "ja_JP"
    return locale.split('_').first.toLowerCase();
  }

  /// Returns the full locale string (e.g. "pt-BR", "en-US")
  static String get localeTag {
    final locale = Platform.localeName;
    return locale.replaceAll('_', '-');
  }

  /// Returns the language name for use in prompts
  static String get languageName {
    const map = {
      'pt': 'português do Brasil',
      'en': 'English',
      'es': 'español',
      'fr': 'français',
      'de': 'Deutsch',
      'it': 'italiano',
      'ja': '日本語',
      'ko': '한국어',
      'zh': '中文',
      'ar': 'العربية',
      'ru': 'русский',
      'hi': 'हिन्दी',
      'th': 'ภาษาไทย',
      'tr': 'Türkçe',
      'nl': 'Nederlands',
      'pl': 'polski',
      'sv': 'svenska',
    };
    return map[languageCode] ?? 'English';
  }
}
