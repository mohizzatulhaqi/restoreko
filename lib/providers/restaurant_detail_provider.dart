import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

class RestaurantDetailState {
  final bool isLoading;
  final bool isSubmitting;
  final Restaurant? restaurant;
  final String? error;

  const RestaurantDetailState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.restaurant,
    this.error,
  });

  RestaurantDetailState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    Restaurant? restaurant,
    String? error,
  }) {
    return RestaurantDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      restaurant: restaurant ?? this.restaurant,
      error: error,
    );
  }
}

class RestaurantDetailProvider extends ChangeNotifier {
  final RestaurantService _service;
  RestaurantDetailProvider({RestaurantService? service})
      : _service = service ?? RestaurantService();

  RestaurantDetailState _state = const RestaurantDetailState();
  RestaurantDetailState get state => _state;

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  Future<void> load(String id) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    try {
      final data = await _service.fetchRestaurantDetail(id);
      _state = RestaurantDetailState(restaurant: data, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: 'Gagal memuat detail: $e');
    }
    notifyListeners();
  }

  Future<bool> submitReview({
    required String id,
    required String name,
    required String review,
  }) async {
    _state = _state.copyWith(isSubmitting: true, error: null);
    notifyListeners();
    try {
      final updated = await _service.submitReview(id: id, name: name, review: review);
      _state = _state.copyWith(restaurant: updated, isSubmitting: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isSubmitting: false, error: e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MM yy', 'id_ID').format(date);
    } catch (_) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
