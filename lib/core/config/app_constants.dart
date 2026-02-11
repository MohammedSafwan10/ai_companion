class AppConstants {
  static const String appName = 'AI Companion';
  static const String appVersion = '1.0.0';

  static const String gemini3Flash = 'gemini-3-flash-preview';
  static const String gemini25Flash = 'gemini-2.5-flash';
  static const String geminiModel = gemini3Flash;

  static const String thinkingKey = 'is_thinking_enabled';

  static const String themeKey = 'theme_mode';
  static const String chatHistoryKey = 'chat_history';
  static const String usageStatsKey = 'usage_stats';
  static const String activityLogKey = 'activity_log';

  static const int maxChatHistory = 50;
  static const int maxActivityEntries = 30;

  static const List<String> supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Japanese',
    'Korean',
    'Chinese',
    'Arabic',
    'Hindi',
    'Bengali',
    'Turkish',
    'Vietnamese',
    'Thai',
    'Indonesian',
    'Malay',
    'Dutch',
    'Polish',
  ];

  static const List<String> programmingLanguages = [
    'Python',
    'JavaScript',
    'TypeScript',
    'Java',
    'C++',
    'C#',
    'Go',
    'Rust',
    'Swift',
    'Kotlin',
    'Dart',
    'PHP',
    'Ruby',
    'SQL',
  ];

  static const List<String> emailTones = [
    'Professional',
    'Friendly',
    'Formal',
    'Casual',
    'Persuasive',
  ];
}
