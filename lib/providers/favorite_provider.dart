import 'package:flutter/foundation.dart';

class FavoriteProvider extends ChangeNotifier {
  final Map<String, bool> _favorites = {};

  bool isFavorite(String restaurantId) {
    return _favorites[restaurantId] ?? false;
  }

  void toggleFavorite(String restaurantId) {
    final current = _favorites[restaurantId] ?? false;
    _favorites[restaurantId] = !current;
    debugPrint('Toggled favorite for $restaurantId to ${_favorites[restaurantId]}');
    notifyListeners();
  }

  List<String> get allFavorites => _favorites.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();
}
