import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _dailyReminderKey = 'daily_reminder_enabled';
  bool? _isDailyReminderEnabled;

  // Initialize the settings service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyReminderEnabled = prefs.getBool(_dailyReminderKey) ?? false;
  }

  // Check if daily reminder is enabled
  bool get isDailyReminderEnabled => _isDailyReminderEnabled ?? false;

  // Toggle daily reminder
  Future<bool> toggleDailyReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyReminderEnabled = value;
    return await prefs.setBool(_dailyReminderKey, value);
  }

  // Set daily reminder
  Future<bool> setDailyReminder(bool enabled) async {
    _isDailyReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_dailyReminderKey, enabled);
  }
}
