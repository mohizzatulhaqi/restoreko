import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_result.dart';
import '../models/restaurant.dart';

class RestaurantService {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';

  Future<List<Restaurant>> fetchRestaurants() async {
    final res = await http.get(Uri.parse('$baseUrl/list'));
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      final List<dynamic> items = data['restaurants'] as List<dynamic>;
      return items
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Gagal ${res.statusCode}');
  }

  Future<Restaurant> fetchRestaurantDetail(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/detail/$id'));
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      if (data['error'] == false && data['restaurant'] != null) {
        return Restaurant.fromJson(data['restaurant'] as Map<String, dynamic>);
      }
      throw Exception('Restoran tidak ditemukan');
    }
    throw Exception('Gagal ${res.statusCode}');
  }

  Future<ApiResult> searchRestaurants(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResult.fromJson(data);
      }
      return ApiResult.error('Gagal memuat hasil');
    } catch (e) {
      return ApiResult.error('Error: $e');
    }
  }

  Future<Restaurant> getRandomRestaurant() async {
    try {
      final restaurants = await fetchRestaurants();
      if (restaurants.isEmpty) {
        throw Exception('Tidak ada restoran yang tersedia');
      }
      final random = restaurants.toList()..shuffle();
      final randomRestaurant = random.first;
      return await fetchRestaurantDetail(randomRestaurant.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<Restaurant> submitReview({
    required String id,
    required String name,
    required String review,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/review'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'id': id, 'name': name, 'review': review}),
          )
          .timeout(const Duration(seconds: 15));

      print('Review submission response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['error'] == false) {
          await Future.delayed(const Duration(milliseconds: 500));

          return await fetchRestaurantDetail(id);
        } else {
          throw Exception(
            'Gagal mengirim ulasan: ${responseData['message'] ?? 'Terjadi kesalahan'}',
          );
        }
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        throw Exception(
          'Permintaan tidak valid: ${responseData['message'] ?? 'Silakan periksa input Anda.'}',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Gagal autentikasi. Silakan coba lagi.');
      } else if (response.statusCode >= 500) {
        throw Exception('Gagal server. Silakan coba lagi nanti.');
      } else {
        throw Exception('Gagal ${response.statusCode}');
      }
    } on FormatException catch (e) {
      print('Format exception: $e');
      throw Exception('Respons tidak valid dari server');
    } on TimeoutException catch (e) {
      print('Timeout exception: $e');
      throw Exception('Permintaan habis waktu. Harap periksa koneksi Anda.');
    } on http.ClientException catch (e) {
      print('Client exception: $e');
      throw Exception('Kesalahan jaringan. Harap periksa koneksi Anda.');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }
}
