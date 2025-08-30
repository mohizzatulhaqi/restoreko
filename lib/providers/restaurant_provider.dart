import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

class RestaurantState {
  final bool isLoading;
  final List<Restaurant> restaurants;
  final String? error;
  final bool isSearching;
  final int searchResultCount;

  const RestaurantState({
    this.isLoading = false,
    this.restaurants = const [],
    this.error,
    this.isSearching = false,
    this.searchResultCount = 0,
  });

  RestaurantState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    String? error,
    bool? isSearching,
    int? searchResultCount,
  }) {
    return RestaurantState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      error: error,
      isSearching: isSearching ?? this.isSearching,
      searchResultCount: searchResultCount ?? this.searchResultCount,
    );
  }
}

class RestaurantProvider extends ChangeNotifier {
  final RestaurantService _service;
  RestaurantProvider({required RestaurantService service}) : _service = service;

  RestaurantState _state = const RestaurantState();
  RestaurantState get state => _state;

  Future<void> fetchRestaurants() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final restaurants = await _service.fetchRestaurants();
      _state = RestaurantState(
        restaurants: restaurants,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Gagal memuat restoran: $e',
      );
    }
    notifyListeners();
  }

  Future<void> searchRestaurants(String query) async {
    if (query.isEmpty) {
      await fetchRestaurants();
      return;
    }

    _state = _state.copyWith(
      isLoading: true,
      isSearching: true,
      error: null,
    );
    notifyListeners();

    try {
      final result = await _service.searchRestaurants(query);
      _state = RestaurantState(
        isLoading: false,
        isSearching: true,
        restaurants: result.restaurants,
        searchResultCount: result.count,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        isSearching: true,
        error: 'Gagal mencari restoran: $e',
      );
    }
    notifyListeners();
  }
}
