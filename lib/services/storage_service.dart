import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setThemeMode(bool isDark) async {
    await _prefs?.setBool(AppConstants.themeKey, isDark);
  }

  static bool getThemeMode() {
    return _prefs?.getBool(AppConstants.themeKey) ?? false;
  }

  static Future<void> saveChatHistory(
    List<Map<String, dynamic>> messages,
  ) async {
    final jsonString = jsonEncode(messages);
    await _prefs?.setString(AppConstants.chatHistoryKey, jsonString);
  }

  static List<Map<String, dynamic>> getChatHistory() {
    final jsonString = _prefs?.getString(AppConstants.chatHistoryKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearChatHistory() async {
    await _prefs?.remove(AppConstants.chatHistoryKey);
  }

  static Future<void> incrementUsage(String feature) async {
    final stats = getUsageStats();
    final currentValue = stats[feature] ?? 0;
    stats[feature] = currentValue + 1;
    await _prefs?.setString(AppConstants.usageStatsKey, jsonEncode(stats));
  }

  static Future<void> recordFeatureUsage({
    required String feature,
    required String description,
  }) async {
    await incrementUsage(feature);
    await addActivity(
      DashboardActivity(
        feature: feature,
        description: description,
        timestamp: DateTime.now(),
      ),
    );
  }

  static Map<String, int> getUsageStats() {
    final jsonString = _prefs?.getString(AppConstants.usageStatsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) {
        final parsedValue = value is num
            ? value.toInt()
            : int.tryParse('$value') ?? 0;
        return MapEntry(key, parsedValue);
      });
    } catch (_) {
      return {};
    }
  }

  static int getUsageCount(String feature) {
    return getUsageStats()[feature] ?? 0;
  }

  static Future<void> resetUsageStats() async {
    await _prefs?.remove(AppConstants.usageStatsKey);
  }

  static Future<void> addActivity(DashboardActivity activity) async {
    final activities = getActivityLog();
    activities.insert(0, activity);

    if (activities.length > AppConstants.maxActivityEntries) {
      activities.removeRange(
        AppConstants.maxActivityEntries,
        activities.length,
      );
    }

    final encoded = activities.map((activity) => activity.toJson()).toList();
    await _prefs?.setString(AppConstants.activityLogKey, jsonEncode(encoded));
  }

  static List<DashboardActivity> getActivityLog({int? limit}) {
    final jsonString = _prefs?.getString(AppConstants.activityLogKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final activities = decoded
          .whereType<Map<String, dynamic>>()
          .map(DashboardActivity.fromJson)
          .toList();

      if (limit != null && activities.length > limit) {
        return activities.sublist(0, limit);
      }

      return activities;
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearActivityLog() async {
    await _prefs?.remove(AppConstants.activityLogKey);
  }
}

class DashboardActivity {
  DashboardActivity({
    required this.feature,
    required this.description,
    required this.timestamp,
  });

  final String feature;
  final String description;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'feature': feature,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    final timestampValue = json['timestamp'];
    DateTime parsedTimestamp;

    if (timestampValue is String) {
      parsedTimestamp = DateTime.tryParse(timestampValue) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return DashboardActivity(
      feature: json['feature'] as String? ?? 'unknown',
      description: json['description'] as String? ?? '',
      timestamp: parsedTimestamp,
    );
  }
}
