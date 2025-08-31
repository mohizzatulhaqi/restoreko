import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _dailyReminderKey = 'daily_reminder_enabled';
  static const String _restaurantRecommendationKey = 'restaurant_recommendation_enabled';
  
  bool _isDailyReminderEnabled = false;
  bool _isRestaurantRecommendationEnabled = false;

  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  bool get isRestaurantRecommendationEnabled => _isRestaurantRecommendationEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyReminderEnabled = prefs.getBool(_dailyReminderKey) ?? false;
    _isRestaurantRecommendationEnabled = 
        prefs.getBool(_restaurantRecommendationKey) ?? false;
    notifyListeners();
  }

  Future<bool> toggleDailyReminder(bool value) async {
    _isDailyReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.setBool(_dailyReminderKey, value);
    notifyListeners();
    return result;
  }

  Future<bool> toggleRestaurantRecommendation(bool value) async {
    _isRestaurantRecommendationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.setBool(_restaurantRecommendationKey, value);
    notifyListeners();
    return result;
  }
}
