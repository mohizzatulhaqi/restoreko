import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _dailyReminderKey = 'daily_reminder_enabled';
  static const String _restaurantRecommendationKey = 'restaurant_recommendation_enabled';
  
  bool? _isDailyReminderEnabled;
  bool? _isRestaurantRecommendationEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyReminderEnabled = prefs.getBool(_dailyReminderKey) ?? false;
    _isRestaurantRecommendationEnabled = prefs.getBool(_restaurantRecommendationKey) ?? false;
  }

  bool get isDailyReminderEnabled => _isDailyReminderEnabled ?? false;

  Future<bool> toggleDailyReminder(bool value) async {
    _isDailyReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_dailyReminderKey, value);
  }

  Future<bool> setDailyReminder(bool enabled) async {
    _isDailyReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_dailyReminderKey, enabled);
  }
  
  bool get isRestaurantRecommendationEnabled => _isRestaurantRecommendationEnabled ?? false;
  
  Future<bool> setRestaurantRecommendation(bool enabled) async {
    _isRestaurantRecommendationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_restaurantRecommendationKey, enabled);
  }
}
