import 'restaurant.dart';

class ApiResult {
  final bool error;
  final String message;
  final int count;
  final List<Restaurant> restaurants;

  ApiResult({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      error: json['error'] as bool,
      message: json['message'] as String? ?? '',
      count: (json['founded'] ?? 0) as int,
      restaurants: (json['restaurants'] as List<dynamic>? ?? [])
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ApiResult.error(String message) {
    return ApiResult(
      error: true,
      message: message,
      count: 0,
      restaurants: [],
    );
  }

  factory ApiResult.success({
    required List<Restaurant> restaurants,
    int? count,
    String message = 'Success',
  }) {
    return ApiResult(
      error: false,
      message: message,
      count: count ?? restaurants.length,
      restaurants: restaurants,
    );
  }
}
