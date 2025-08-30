import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restoreko/database/database_helper.dart';
import 'package:restoreko/models/restaurant.dart';
import 'package:collection/collection.dart';

class FavoriteProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<Restaurant> _favorites = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  List<Restaurant> get favorites => _favorites;
  String? get error => _error;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadFavorites() async {
    if (_isDisposed) return;
    
    _isLoading = true;
    _error = null;
    
    try {
      final List<Map<String, dynamic>> favoriteMaps = 
          await _dbHelper.getFavorites();
      final newFavorites = favoriteMaps.map((map) => Restaurant.fromJson(map)).toList();
      
      if (newFavorites.length != _favorites.length || 
          !const DeepCollectionEquality().equals(
            newFavorites.map((r) => r.id).toList(),
            _favorites.map((r) => r.id).toList(),
          )) {
        _favorites.clear();
        _favorites.addAll(newFavorites);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            notifyListeners();
          }
        });
      }
    }
  }

  Future<bool> isFavorite(String restaurantId) async {
    return await _dbHelper.isFavorite(restaurantId);
  }

  Future<void> toggleFavorite(Restaurant restaurant) async {
    if (_isDisposed) return;
    
    try {
      final isFav = await _dbHelper.isFavorite(restaurant.id);
      
      if (isFav) {
        await _dbHelper.deleteFavorite(restaurant.id);
        _favorites.removeWhere((r) => r.id == restaurant.id);
      } else {
        await _dbHelper.insertFavorite(restaurant);
        _favorites.add(restaurant);
      }
      
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            notifyListeners();
          }
        });
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<List<String>> getAllFavoriteIds() async {
    final favorites = await _dbHelper.getFavorites();
    return favorites.map((map) => map['id'] as String).toList();
  }

  Future<void> clearFavorites() async {
    try {
      final db = await _dbHelper.database;
      await db.delete('favorites');
      _favorites.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }
}
