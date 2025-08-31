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
  final String? submitError; // Separate error for review submission

  const RestaurantDetailState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.restaurant,
    this.error,
    this.submitError,
  });

  RestaurantDetailState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    Restaurant? restaurant,
    String? error,
    String? submitError,
  }) {
    return RestaurantDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      restaurant: restaurant ?? this.restaurant,
      error: error,
      submitError: submitError,
    );
  }
}

class RestaurantDetailProvider extends ChangeNotifier {
  final RestaurantService _service;

  RestaurantDetailProvider({required RestaurantService service})
    : _service = service;

  RestaurantDetailState _state = const RestaurantDetailState();
  RestaurantDetailState get state => _state;

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  bool _isDescriptionExpanded = false;
  bool get isDescriptionExpanded => _isDescriptionExpanded;

  void toggleDescriptionExpanded() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  void clearSubmitError() {
    if (_state.submitError != null) {
      _state = _state.copyWith(submitError: null);
      notifyListeners();
    }
  }

  Future<void> load(String id) async {
    _state = _state.copyWith(isLoading: true, error: null, submitError: null);
    notifyListeners();

    try {
      final data = await _service.fetchRestaurantDetail(id);
      _state = _state.copyWith(restaurant: data, isLoading: false, error: null);
    } catch (e) {
      print('Error loading restaurant detail: $e');
      _state = _state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data. Silakan periksa koneksi internet Anda.',
      );
    }
    notifyListeners();
  }

  Future<void> refresh(String id) async {
    try {
      final data = await _service.fetchRestaurantDetail(id);
      _state = _state.copyWith(
        restaurant: data,
        error: null,
        submitError: null,
      );
      notifyListeners();
    } catch (e) {
      print('Error refreshing restaurant detail: $e');
      // Don't update error state on refresh failure, just log it
    }
  }

  Future<bool> submitReview({
    required String id,
    required String name,
    required String review,
  }) async {
    // Clear any previous submit errors
    _state = _state.copyWith(isSubmitting: true, submitError: null);
    notifyListeners();

    try {
      // Get current restaurant data
      final currentRestaurant = _state.restaurant;
      if (currentRestaurant == null) {
        _state = _state.copyWith(
          isSubmitting: false,
          submitError: 'Data restoran tidak tersedia',
        );
        notifyListeners();
        return false;
      }

      print('Submitting review for restaurant: $id');
      print('Review data - Name: $name, Review: $review');

      // Submit the review and get the complete updated restaurant data
      final updatedRestaurant = await _service.submitReview(
        id: id,
        name: name,
        review: review,
      );

      print('Review submitted successfully');
      print(
        'Updated restaurant reviews count: ${updatedRestaurant.customerReviews.length}',
      );

      // Update the state with the complete restaurant data
      _state = _state.copyWith(
        restaurant: updatedRestaurant,
        isSubmitting: false,
        error: null,
        submitError: null,
      );
      notifyListeners();

      // Scroll to the bottom to show the new review after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollToBottom();
      });

      return true;
    } catch (e) {
      print('Error submitting review: $e');
      _state = _state.copyWith(
        isSubmitting: false,
        submitError: e.toString().replaceFirst('Exception: ', ''),
      );
      notifyListeners();
      return false;
    }
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
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
